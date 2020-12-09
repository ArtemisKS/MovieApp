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
    func onScrolledToBottom()
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
    
    struct LocalData {
        var movies: [MovieModel]?
        var resMovies: [MovieModel] = []
        
        var lastTapTime: Date?
        let debounceTime: TimeInterval = 1
        var timer: Timer?
        
        var postersDict: [UInt64 : UIImage] = [:]
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
        Pages.maxPageNum
    }
    
    private struct Pages {
        static var maxLoadedPage: Int = 1
        static var maxPageNum: Int = 1
        static var minPageNum: Int = 1
        
        static func setMaxPages(page: Int) {
            maxPageNum = page
            maxLoadedPage = page + 1
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
        fetchUpdate(fetchCase: .reload)
    }
    
    func onScrolledToBottom() {
        Pages.maxPageNum += 1
        self.fetchUpdate(fetchCase: .loadMore)
    }
    
    func didTapOnCell(index: Int) {
        if let movie = dataSource?[index] {
            router.showDetail(with: movie, and: imagesDict[movie.id])
        }
    }
    
    func processSearchText(_ text: String) {
        
        guard !text.isEmpty,
              let movies = data.movies else { return }
        
        self.data.lastTapTime = Date()
        
        invalidateTimer()
        
        data.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if Date() - self.data.lastTapTime! >= 1 {
                self.doSearchTextProcessing(text, movies: movies)
                timer.invalidate()
            }
        }
    }
    
    private func invalidateTimer() {
        if data.timer != nil {
            data.timer?.invalidate()
            data.timer = nil
        }
    }
    
    private func doSearchTextProcessing(_ text: String, movies: [MovieModel]) {
        data.resMovies.removeAll()
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
            invalidateTimer()
            isSearchOngoing = false
            updateView(error: nil)
        }
    }
    
    private func fetchUpdate(fetchCase: FetchCase) {
        fetchMovies { [weak self] (movies, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
        
        if let error = error {
            view?.handleStateChange(.error(error))
        } else {
            var cellModels: [CellModeling]
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
    
    private func fetchMovies(completion: @escaping ([MovieModel], Error?) -> Void) {
        
        let group = DispatchGroup()
        var error: Error?
        
        var pageLoaded = -1
        var movies: [MovieModel] = []
        
        func extractMoviesData(_ data: MoviesModel) {
            pageLoaded = max(pageLoaded, data.page)
            movies.append(contentsOf: data.results)
        }
        
        for page in Pages.maxLoadedPage...curMaxPage {
            if let data = DefaultsManager.getEntity(by: .moviesModel, id: Utils.getString(from: page)) as MoviesModel? {
                extractMoviesData(data)
                continue
            }
            group.enter()
            movieService.getMovies(page: page) { (result) in
                switch result {
                case .success(let data):
                    extractMoviesData(data)
                    DefaultsManager.set(
                        entity: data,
                        by: .moviesModel,
                        id: Utils.getString(from: data.page))
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
            Pages.setMaxPages(page: pageLoaded)
            return resErr
        }
        
        group.notify(
            queue: .main,
            execute: {
                var resErr: Error? = error
                if resErr == nil {
                    resErr = checkForPageNumError()
                }
                if resErr == nil {
                    if self.data.movies == nil {
                        self.data.movies = movies
                    } else {
                        self.data.movies?.append(contentsOf: movies)
                    }
                }
                completion(movies, resErr)
            })
    }
    
    private func makeCellModels() -> [CellModeling] {
        var cellModels: [CellModeling] = []
        
        guard let movies = data.movies else { return cellModels }
        
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
