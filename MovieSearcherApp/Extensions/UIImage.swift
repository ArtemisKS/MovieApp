//
//  UIImage.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

enum Images: String, CaseIterable {
    case lordOrTheRings = "posterLOR"
}

extension UIImage {
    class func getImage(for image: Images) -> UIImage {
        UIImage(named: image.rawValue) ?? UIImage()
    }
}
