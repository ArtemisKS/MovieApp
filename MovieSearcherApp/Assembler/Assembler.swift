//
//  Assembler.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit

protocol AssemblerBuilderProtocol {
  func createDetailController(router: RouterProtocol) -> UIViewController
  func createMainController(router: RouterProtocol) -> UIViewController
}

class AssemblerBuilder: AssemblerBuilderProtocol {
  func createDetailController(router: RouterProtocol) -> UIViewController {
    let view = DetailViewController.loadFromNib()
    let presenter = DetailPresenter(view: view, router: router)
    view.presenter = presenter
    return view
  }
  
  func createMainController(router: RouterProtocol) -> UIViewController {
    let view = MainViewController.loadFromNib()
    let apiManager = APIManager()
    let movieService = MovieService(apiManager: apiManager, baseURL: URLManager.baseURL)
    let presenter = MainPresenter(movieService: movieService, view: view, router: router)
    view.presenter = presenter
    return view
  }
  
}
