//
//  Router.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Foundation
import UIKit

protocol RouterFirst {
  var navigationController: UINavigationController? { get set }
  var assembler: AssemblerBuilderProtocol? { get set }
}

protocol RouterProtocol: RouterFirst {
  func setInitialViewController()
//  func showDetail(with data: [MovieModel]?)
  func popToRoot()
}

class Router: RouterProtocol {
  var navigationController: UINavigationController?
  var assembler: AssemblerBuilderProtocol?
  
  init(navigationController: UINavigationController, assembler: AssemblerBuilderProtocol) {
    self.navigationController = navigationController
    self.assembler = assembler
  }
  
  func setInitialViewController() {
    if let navigationController = navigationController {
        guard let firstVC = assembler?.createMainController(router: self) else { return }
      navigationController.viewControllers = [firstVC]
    }
  }
  
//  func showDetail(with data: [MovieModel]?) {
//    if let navigationController = navigationController {
//      guard let firstVC = assembler?.createMainController(data: data, router: self) else { return }
//      navigationController.pushViewController(firstVC, animated: true)
//    }
//  }
  
  func popToRoot() {
    if let navigationController = navigationController {
      navigationController.popViewController(animated: true)
    }
  }
  
}
