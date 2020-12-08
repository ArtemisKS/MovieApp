//
//  UIViewController.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit

extension UIViewController {
    
    var isDarkMode: Bool {
        view.isDarkMode
    }
    
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        
        return instantiateFromNib()
    }
    
    //MARK: -  Alert with OK button
    func showAlert(
        title: String?,
        message: String?,
        okAction: (() -> Void)? = nil,
        completion: (() -> Void)? = nil) {
      
      let alertController = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert)
        
      let OKAction = UIAlertAction(
        title: "ОК",
        style: .default,
        handler: { (action) in
          if let okAction = okAction {
            okAction()
          }
      })
      alertController.addAction(OKAction)
      
      DispatchQueue.main.async {
        self.present(alertController, animated: true, completion: completion)
      }
    }
}
