//
//  UIView.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

extension UIView {
    
    var isDarkMode: Bool {
      if #available(iOS 13.0, *) {
        return traitCollection.userInterfaceStyle == .dark
      } else {
        return false
      }
    }
}
