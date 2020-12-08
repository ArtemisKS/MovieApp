//
//  MainMoviePresenter.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit
import Alamofire

enum ListState<T> {
    case loading
    case initial(items: [T])
    case loadedMore(items: [T])
    case updated(items: [T])
    case error(Error?)
}

@propertyWrapper
struct Atomic<Value> {

    private var value: Value
    private let lock = NSLock()

    init(wrappedValue value: Value) {
        self.value = value
    }

    var wrappedValue: Value {
      get { return load() }
      set { store(newValue: newValue) }
    }

    private func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    private mutating func store(newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}

enum BasicError: Error {
    case withCode(Int)
    case withMessage(String)
}

protocol MainViewPresenterProtocol: class {
    
    var dataLoaded: Bool { get }
    var curMaxPage: Int { get }
    
    init(
        movieService: MovieServiceProtocol,
        view: MainViewProtocol,
        router: RouterProtocol)
    
    func onViewDidLoad()
    func onScrolledToBottom()
    func save()
    func fetchIcon(for cell: ImageViewCell, index: Int)
}

class MainPresenter: MainViewPresenterProtocol {
    
    var movieService: MovieServiceProtocol
    weak var view: MainViewProtocol?
    var router: RouterProtocol
    
    private let cellFactory = DBTransactionCellModelsFactory()
    private var postersDict: [UInt64 : UIImage] = [:]
    @Atomic private var movies: [MovieModel]?
    
    var dataLoaded: Bool {
        movies != nil
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
    
    private func fetchUpdate(fetchCase: FetchCase) {
        fetchMovies { [weak self] (movies, error) in
            DispatchQueue.main.async {
                let movies: [MovieModel]? = fetchCase == .loadMore ?
                    movies : nil
                self?.updateView(with: error, loadedMoreMovies: movies)
            }
        }
    }
    
    private func updateView(with error: Error?, loadedMoreMovies: [MovieModel]?) {
        if let error = error {
            view?.handleStateChange(.error(error))
        } else {
            var cellModels: [CellModeling]
            if let movies = loadedMoreMovies {
                cellModels = getCellModels(from: movies)
                view?.handleStateChange(.loadedMore(items: cellModels))
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
        
        for page in Pages.maxLoadedPage...curMaxPage {
            group.enter()
            movieService.getMovies(page: page) { (result) in
                switch result {
                case .success(let data):
                    pageLoaded = max(pageLoaded, data.page)
                    movies.append(contentsOf: data.results)
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
                    if self.movies == nil {
                        self.movies = movies
                    } else {
                        self.movies?.append(contentsOf: movies)
                    }
                }
                completion(movies, resErr)
            })
    }
    
    private func makeCellModels() -> [CellModeling] {
        var cellModels: [CellModeling] = []
        
        guard let movies = movies else { return cellModels }
        
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
        guard let movies = movies,
              index < movies.count else { return }
        
        fetchIcon(for: cell, movie: movies[index])
    }
    
    func save() {
        //TODO: implement save
    }
    
    @objc private func popToRoot() {
//        router?.popToRoot()
    }
    
}

extension MainPresenter: ImageLoader {
    
    var imagesDict: [UInt64 : UIImage] {
        get { postersDict }
        set { postersDict = newValue }
    }
}
