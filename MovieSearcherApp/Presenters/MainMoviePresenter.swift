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
    
    init(
        movieService: MovieServiceProtocol,
        view: MainViewProtocol,
        router: RouterProtocol)
    
    func onViewDidLoad()
    func save()
    func fetchIcon(for cell: ImageViewCell, index: Int)
}

class MainPresenter: MainViewPresenterProtocol {
    
    var movieService: MovieServiceProtocol
    weak var view: MainViewProtocol?
    var router: RouterProtocol
    
    private let cellFactory = DBTransactionCellModelsFactory()
    private var pageNum: Int = 1
    private var postersDict: [UInt64 : UIImage] = [:]
    @Atomic private var movies: [MovieModel]?
    
    var dataLoaded: Bool {
        movies != nil
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
        fetchMovies { (error) in
            self.updateView(with: error)
        }
    }
    
    private func updateView(with error: Error?) {
        if let error = error {
            view?.handleStateChange(.error(error))
        } else {
            let cellModels = makeCellModels()
            view?.handleStateChange(.initial(items: cellModels))
        }
    }
    
    private func fetchMovies(completion: @escaping (Error?) -> Void) {
        
        let group = DispatchGroup()
        var error: Error?
        
        var pageLoaded = -1
        
        for page in 1...pageNum {
            group.enter()
            movieService.getMovies(page: page) { (result) in
                switch result {
                case .success(let data):
                    pageLoaded = max(pageLoaded, data.page)
                    if self.movies == nil {
                        self.movies = data.results
                    } else {
                        self.movies?.append(contentsOf: data.results)
                    }
                case .failure(let err):
                    error = err
                }
                group.leave()
            }
        }
        
        func checkForPageNumError() -> Error? {
            var resErr: Error?
            if pageLoaded < pageNum {
                let pages: [Int] = .init(pageLoaded...pageNum)
                resErr = BasicError.withMessage(
                    """
                    Couldn't load page\(pages.count > 1 ? "s" : "") \(pages.enumerated().map { $0 == pages.count - 1 ? "\($1), " : "\($1)" })
                    """)
            }
            return resErr
        }
        
        group.notify(
            queue: .main,
            execute: {
                var resErr: Error? = error
                if resErr == nil {
                    resErr = checkForPageNumError()
                }
                completion(resErr)
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
