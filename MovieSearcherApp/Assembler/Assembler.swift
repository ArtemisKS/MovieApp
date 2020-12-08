//
//  Assembler.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit

protocol AssemblerBuilderProtocol {
    func createDetailController(
        data: (movie: MovieModel, poster: UIImage?),
        router: RouterProtocol) -> UIViewController
    func createMainController(router: RouterProtocol) -> UIViewController
}

class AssemblerBuilder: AssemblerBuilderProtocol {
    
    let apiManager = APIManager()
    
    func createDetailController(
        data: (movie: MovieModel, poster: UIImage?),
        router: RouterProtocol) -> UIViewController {
        let view = DetailViewController.loadFromNib()
        view.setPoster(data.poster)
        let movieService = MovieService(apiManager: apiManager, baseURL: URLManager.baseURL)
        let presenter = DetailPresenter(
            data: data.movie,
            movieService: movieService,
            view: view,
            
            router: router)
        view.presenter = presenter
        return view
    }
    
    func createMainController(router: RouterProtocol) -> UIViewController {
        let view = MainViewController.loadFromNib()
        let movieService = MovieService(apiManager: apiManager, baseURL: URLManager.baseURL)
        let presenter = MainPresenter(movieService: movieService, view: view, router: router)
        view.presenter = presenter
        return view
    }
    
}
