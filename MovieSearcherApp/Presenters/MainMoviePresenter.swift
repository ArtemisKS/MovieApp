//
//  MainMoviePresenter.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit
import Alamofire

protocol MainViewPresenterProtocol: class {
    
    var dataLoaded: Bool { get }
    var isSearchOngoing: Bool { get }
    var localSearch: Bool { get }
    
    init(
        movieService: MovieServiceProtocol,
        view: MainViewProtocol,
        router: RouterProtocol)
    
    func onViewDidLoad()
    func onTableViewRefresh()
    func onScrolledToBottom(query: String?)
    func didTapOnCell(index: Int)
    func fetchIcon(for cell: ImageViewCell, index: Int)
    func processSearchText(_ text: String)
    func clearAndResignSearch()
}

class MainPresenter: MainViewPresenterProtocol {
    
    var movieService: MovieServiceProtocol
    weak var view: MainViewProtocol?
    var router: RouterProtocol
    private let cellFactory = DBTransactionCellModelsFactory()
    @Atomic private var data = LocalData()
    private var pages = Pages()
    
    private(set) var localSearch = false
    
    private class LocalData {
        var movies: [MovieModel]?
        var resMovies: [MovieModel] = []
        
        var lastTapTime: Date?
        let debounceTime: TimeInterval = 1
        var timer: Timer?
        
        var prevQuery: String = ""
        
        var postersDict: [UInt64 : UIImage] = [:]
        
        func resetData() {
            movies = nil
            resMovies = []
            postersDict = [:]
        }
    }
    
    private var forSearch = false {
        didSet {
            pages.setForSearch(forSearch)
        }
    }
    
    private(set) var isSearchOngoing = false {
        willSet {
            view?.updateSearchLabel(hidden: !newValue, count: data.resMovies.count)
        }
    }
    
    private var dataSource: [MovieModel]? {
        isSearchOngoing ? data.resMovies : data.movies
    }
    
    var dataLoaded: Bool {
        data.movies != nil
    }
    
    private var curMaxPage: Int {
        pages.maxPageNum
    }
    
    private var inetOK: Bool {
        Utils.internetConnectionOK
    }
    
    private class Pages {
        private var maxLoadedMoviesPage: Int = 1
        private var maxPageMoviesNum: Int = 1
        private var minPageMoviesNum: Int = 1
        
        private var maxLoadedSearchPage: Int = 1
        private var maxPageSearchNum: Int = 1
        private var minPageSearchNum: Int = 1
        
        private var forSearch = false
        
        var maxLoadedPage: Int {
            get {
                forSearch ? maxLoadedSearchPage : maxLoadedMoviesPage
            } set {
                if forSearch {
                    maxLoadedSearchPage = newValue
                } else {
                    maxLoadedMoviesPage = newValue
                }
            }
        }
        
        var maxPageNum: Int {
            get {
                forSearch ? maxPageMoviesNum : maxPageSearchNum
            } set {
                if forSearch {
                    maxPageMoviesNum = newValue
                } else {
                    maxPageSearchNum = newValue
                }
            }
        }
        
        var minPageNum: Int {
            get {
                forSearch ? minPageMoviesNum : minPageSearchNum
            } set {
                if forSearch {
                    minPageMoviesNum = newValue
                } else {
                    minPageSearchNum = newValue
                }
            }
        }
        
        func setMaxPages(page: Int) {
            maxPageNum = page
            maxLoadedPage = page + 1
        }
        
        func resetPages() {
            maxPageNum = 1
            maxLoadedPage = 1
            minPageNum = 1
        }
        
        func setForSearch(_ forSearch: Bool) {
            if self.forSearch && !forSearch {
                resetPages()
            }
            self.forSearch = forSearch
        }
    }
    
    private enum FetchCase {
        case reload
        case loadMore
    }
    
    required init(
        movieService: MovieServiceProtocol,
        view: MainViewProtocol,
        router: RouterProtocol) {
        
        self.movieService = movieService
        self.view = view
        self.router = router
    }
    
    func onViewDidLoad() {
        doFullDataFetch()
    }
    
    func onScrolledToBottom(query: String?) {
        pages.maxPageNum += 1
        fetchUpdate(query: query, fetchCase: .loadMore)
    }
    
    func onTableViewRefresh() {
        resetData()
        doFullDataFetch()
    }
    
    private func resetData() {
        DefaultsManager.resetDefaults()
        data.resetData()
        pages.resetPages()
    }
    
    private func doFullDataFetch() {
        view?.setLoading(loading: true)
        fetchUpdate(query: nil, fetchCase: .reload)
    }
    
    func didTapOnCell(index: Int) {
        if let movie = dataSource?[index] {
            router.showDetail(with: movie, and: imagesDict[movie.id])
        }
    }
    
    func processSearchText(_ text: String) {
        
        guard let movies = data.movies else { return }
        
        data.lastTapTime = Date()
        
        invalidateTimer()
        
        data.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (timer) in
            guard let self = self else { return }
            if Date() - self.data.lastTapTime! >= 1 {
                self.doSearchTextProcessing(text, movies: movies)
                self.invalidateTimer(timer: timer)
            }
        }
    }
    
    private func invalidateTimer(timer: Timer? = nil) {
        var timer = timer ?? data.timer
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func doSearchTextProcessing(_ text: String, movies: [MovieModel]) {
        if text.isEmpty {
            reloadWithUsualList()
            return
        }
        if text.trimmed == data.prevQuery.trimmed { return }
        
        data.resMovies.removeAll()
        let query = text.trimmed.filter { !($0.isNewline || $0.isWhitespace) }.lowercased()
        let hasSearchRes = DefaultsManager.hasEntity(
            by: .searchMovieModel,
            id: Utils.getString(from: 1, and: query))
        localSearch = !inetOK && !hasSearchRes
        forSearch = true
        pages.resetPages()
        if !localSearch {
            fetchMovies(query: query) { (movies, error) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let movies: [MovieModel]? = self.pages.maxLoadedPage > 2 ?
                        movies : nil
                    self.updateView(error: error, loadedMoreMovies: movies)
                }
            }
        } else {
            processSearchWhenOffline(text, movies: movies)
        }
    }
    
    private func processSearchWhenOffline(_ text: String, movies: [MovieModel]) {
        for word in text.components(separatedBy: " ") {
            data.resMovies.append(contentsOf: movies.filter { movie in
                let match = movie.title.range(of: word, options: .caseInsensitive)
                return match != nil
            })
            data.resMovies = Array(Set(data.resMovies))
        }
        data.prevQuery = text
        isSearchOngoing = true
        updateView(error: nil, searchResultMovies: data.resMovies)
    }
    
    func clearAndResignSearch() {
        if isSearchOngoing {
            reloadWithUsualList()
        }
    }
    
    private func reloadWithUsualList() {
        data.prevQuery = ""
        forSearch = false
        isSearchOngoing = false
        invalidateTimer()
        updateView(error: nil)
    }
    
    private func fetchUpdate(query: String?, fetchCase: FetchCase) {
        fetchMovies(query: query) { (movies, error) in
            DispatchQueue.main.async {  [weak self] in
                let movies: [MovieModel]? = fetchCase == .loadMore ?
                    movies : nil
                self?.updateView(error: error, loadedMoreMovies: movies)
            }
        }
    }
    
    private func updateView(
        error: Error?,
        loadedMoreMovies: [MovieModel]? = nil,
        searchResultMovies: [MovieModel]? = nil) {
        
        view?.setLoading(loading: false)
        view?.setSearchBar(hidden: false)
        
        if let error = error {
            view?.handleStateChange(.error(error))
        } else {
            var cellModels: [CellModeling]
            isSearchOngoing = forSearch
            if let movies = loadedMoreMovies {
                cellModels = getCellModels(from: movies)
                view?.handleStateChange(.loadedMore(items: cellModels))
            } else if let movies = searchResultMovies {
                cellModels = getCellModels(from: movies)
                view?.handleStateChange(.initial(items: cellModels))
            } else {
                cellModels = makeCellModels()
                view?.handleStateChange(.initial(items: cellModels))
            }
        }
    }
    
    private func fetchMovies(
        query: String?,
        completion: @escaping ([MovieModel], Error?) -> Void) {
        
        let group = DispatchGroup()
        var error: Error?
        
        var pageLoaded = -1
        var movies: [MovieModel] = []
        
        let forSearch = query != nil
        let defStorageKey: DefaultsStorageKey = !forSearch
            ? .moviesModel : .searchMovieModel
        
        func extractMoviesData(_ data: MoviesModel) {
            pageLoaded = max(pageLoaded, data.page)
            movies.append(contentsOf: data.results)
        }
        
        self.forSearch = forSearch
        if pages.maxLoadedPage > curMaxPage {
            pages.resetPages()
        }
        for page in pages.maxLoadedPage...curMaxPage {
            
            if let data = DefaultsManager.getEntity(by: defStorageKey, id: Utils.getString(from: page, and: query)) as MoviesModel? {
                extractMoviesData(data)
                continue
            }
            if !inetOK { continue }
            group.enter()
            
            let reqData = GetMoviesReqData(
                page: page,
                query: query,
                includeAdult: false)
            let requestClosure: (GetMoviesReqData, @escaping MovieServiceProtocol.GetMoviesCompletion) -> Void = forSearch ?
                movieService.getMoviesSearch :
                movieService.getMovies
            requestClosure(reqData) { (result) in
                switch result {
                case .success(let data):
                    extractMoviesData(data)
                    DefaultsManager.set(
                        entity: data,
                        by: defStorageKey,
                        id: Utils.getString(from: data.page, and: query))
                case .failure(let err):
                    error = err
                }
                group.leave()
            }
        }
        
        group.notify(
            queue: .main,
            execute: {
                self.pages.setMaxPages(page: pageLoaded)
                var resMovies = forSearch ?
                    self.data.resMovies : self.data.movies
                if error == nil {
                    if resMovies == nil {
                        resMovies = movies
                    } else {
                        resMovies?.append(contentsOf: movies)
                    }
                    self.data.prevQuery = query ?? ""
                }
                if forSearch {
                    self.data.resMovies = resMovies ?? []
                } else {
                    self.data.movies = resMovies
                }
                completion(movies, error)
            })
    }
    
    private func makeCellModels() -> [CellModeling] {
        var cellModels: [CellModeling] = []
        
        guard let movies = forSearch ? data.resMovies : data.movies else { return cellModels }
        
        for movie in movies {
            cellModels.append(
                cellFactory.movieCellModel(title: movie.title))
        }
        
        return cellModels
    }
    
    private func getCellModels(from movies: [MovieModel]) -> [CellModeling] {
        movies.map { cellFactory.movieCellModel(title: $0.title) }
    }
    
    func fetchIcon(for cell: ImageViewCell, index: Int) {
        guard let movies = dataSource,
              index < movies.count else { return }
        
        fetchIcon(for: cell, movie: movies[index])
    }
    
}

extension MainPresenter: ImageLoader {
    
    var imagesDict: [UInt64 : UIImage] {
        get { data.postersDict }
        set { data.postersDict = newValue }
    }
}
