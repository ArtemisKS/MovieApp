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
    
    @IBInspectable
    var isRound: Bool {
        get {
            layer.masksToBounds
        } set {
            setRounded(newValue)
        }
    }
    
    var halfRadius: CGFloat {
        frame.width > frame.height ? frame.height / 2 : frame.width / 2
    }
    
    private func setRounded(_ rounded: Bool) {
        layer.cornerRadius = rounded ? halfRadius : 0
        layer.masksToBounds = rounded
    }
    
    func setCornerRadius(_ radius: CGFloat = 4, corners: UIRectCorner? = nil) {
      if let corners = corners {
        let path = UIBezierPath(
          roundedRect: bounds,
          byRoundingCorners: corners,
          cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask

      } else {
        layer.cornerRadius = radius
        layer.masksToBounds = true
      }
    }
}
