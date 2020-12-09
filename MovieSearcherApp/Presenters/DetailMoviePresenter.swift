//
//  DetailMoviePresenter.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit

protocol DetailViewProtocol: class {
    func updateView(
        with movie: MovieDetail?,
        error: Error?)
    func setLoading(loading: Bool)
    func setPoster(_ image: UIImage?)
}

protocol DetailViewPresenterProtocol: class {
    
    var movieData: MovieModel { get }
    
    init(
        data: MovieModel,
        movieService: MovieServiceProtocol,
        view: DetailViewProtocol,
        router: RouterProtocol)
    //  var data: [MovieModel]? { get set }
    func onViewLoaded()
}

class DetailPresenter: DetailViewPresenterProtocol {
    
    private let data: MovieModel
    private let movieService: MovieServiceProtocol
    weak var view: DetailViewProtocol?
    var router: RouterProtocol
    private var movie: MovieDetail?
    
    var movieData: MovieModel {
        data
    }
    
    required init(
        data: MovieModel,
        movieService: MovieServiceProtocol,
        view: DetailViewProtocol,
        router: RouterProtocol) {
        
        self.data = data
        self.movieService = movieService
        self.view = view
        self.router = router
    }
    
    func onViewLoaded() {
        view?.setLoading(loading: true)
        fetchMovie { (error) in
            self.view?.updateView(with: self.movie, error: error)
        }
    }
    
    private func fetchMovie(completion: @escaping (Error?) -> Void) {
        
        if let movie = DefaultsManager.getEntity(by: .moviesModel, id: Utils.getString(from: data.id)) as MovieDetail? {
            self.movie = movie
            completion(nil)
            return
        }
        
        movieService.getMovieDetails(id: "\(data.id)") { (result) in
            switch result {
            case .success(let data):
                self.movie = data
                DefaultsManager.set(
                    entity: data,
                    by: .movieDetail,
                    id: Utils.getString(from: data.id))
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
}
