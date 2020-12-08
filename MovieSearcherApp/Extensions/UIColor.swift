//
//  UIColor.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit

extension UIColor {
    
    class var mainBlue: UIColor {
        .init(red: 0.1, green: 0.64, blue: 0.94, alpha: 1)
    }
    
    class var customBlue: UIColor {
        .getColor(r: 89, g: 151, b: 227)
    }
    
    private class func valueMod(_ val: Int) -> CGFloat {
        let maxVal = 256
        let res = Double(val % maxVal)
        return CGFloat(res / Double(maxVal))
    }
    
    class func getMonoColor(rgb: Int, alpha: CGFloat = 1) -> UIColor {
        let val: CGFloat = valueMod(rgb)
        return .init(red: val, green: val, blue: val, alpha: alpha)
    }
    
    class func getColor(r: Int, g: Int, b: Int, alpha: CGFloat = 1) -> UIColor {
        .init(red: valueMod(r), green: valueMod(g), blue: valueMod(b), alpha: alpha)
    }
    
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

