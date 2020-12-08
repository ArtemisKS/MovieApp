//
//  UIColor.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit

extension UIColor {
  
  class var systemBlack: UIColor {
    return UIColor.black.getCustomColor(name: "SystemBlack")
  }
  
  class var systemWhite: UIColor {
    return UIColor.black.getCustomColor(name: "SystemWhite")
  }
  
  func getCustomColor(name: String) -> UIColor {
    if #available(iOS 11, *) {
      return UIColor(named: name) ?? self
    }
    return self
  }
  
}
