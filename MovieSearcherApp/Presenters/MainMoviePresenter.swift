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
    var curMaxPage: Int { get }
    var isSearchOngoing: Bool { get }
    
    init(
        movieService: MovieServiceProtocol,
        view: MainViewProtocol,
        router: RouterProtocol)
    
    func onViewDidLoad()
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
    
    private class LocalData {
        var movies: [MovieModel]?
        var resMovies: [MovieModel] = []
        
        var lastTapTime: Date?
        let debounceTime: TimeInterval = 1
        var timer: Timer?
        
        var postersDict: [UInt64 : UIImage] = [:]
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
    
    var curMaxPage: Int {
        pages.maxPageNum
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
        view?.setLoading(loading: true)
        fetchUpdate(query: nil, fetchCase: .reload)
    }
    
    func onScrolledToBottom(query: String?) {
        pages.maxPageNum += 1
        self.fetchUpdate(query: query, fetchCase: .loadMore)
    }
    
    func didTapOnCell(index: Int) {
        if let movie = dataSource?[index] {
            router.showDetail(with: movie, and: imagesDict[movie.id])
        }
    }
    
    func processSearchText(_ text: String) {
        
        guard let movies = data.movies else { return }
        
        self.data.lastTapTime = Date()
        
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
        data.resMovies.removeAll()
        if Utils.internetConnectionOK {
            fetchMovies(query: text) { (movies, error) in
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
                return match != nil && !data.resMovies.contains(where: { mov -> Bool in
                    return mov.title == movie.title
                })
            })
        }
        isSearchOngoing = true
        updateView(error: nil, searchResultMovies: data.resMovies)
    }
    
    func clearAndResignSearch() {
        if isSearchOngoing {
            self.forSearch = false
            invalidateTimer()
            reloadWithUsualList()
        }
    }
    
    private func reloadWithUsualList() {
        isSearchOngoing = false
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
            self.isSearchOngoing = self.forSearch
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
        
        func checkForPageNumError() -> Error? {
            var resErr: Error?
            if pageLoaded < curMaxPage {
                let pages = pageLoaded...curMaxPage
                resErr = BasicError.withMessage(
                    """
                    Couldn't load page\(pages.count > 1 ? "s" : "") \(pages.enumerated().map { $0 == pages.count - 1 ? "\($1), " : "\($1)" })
                    """)
            }
            pages.setMaxPages(page: pageLoaded)
            return resErr
        }
        
        group.notify(
            queue: .main,
            execute: {
                var resErr: Error? = error
                if resErr == nil {
                    resErr = checkForPageNumError()
                }
                var resMovies = forSearch ?
                    self.data.resMovies : self.data.movies
                if resErr == nil {
                    if resMovies == nil {
                        resMovies = movies
                    } else {
                        resMovies?.append(contentsOf: movies)
                    }
                }
                if forSearch {
                    self.data.resMovies = resMovies ?? []
                } else {
                    self.data.movies = resMovies
                }
                completion(movies, resErr)
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
