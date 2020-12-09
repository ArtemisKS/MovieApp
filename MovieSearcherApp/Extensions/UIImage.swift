//
//  UIImage.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

enum Images: String, CaseIterable {
    case lordOrTheRings = "posterLOR"
    case moviePosterPlaceholder = "moviePosterPlaceholder"
}

class ImageData {
    let image: UIImage?
    let ratio: CGFloat
    
    init(image: UIImage, ratio: CGFloat) {
        self.image = image
        self.ratio = ratio
    }
}

extension UIImage {
    class func getImage(for image: Images) -> UIImage {
        UIImage(named: image.rawValue) ?? UIImage()
    }
    
    func resizeImage(targetSize: CGSize) -> ImageData? {
        
        let ratio = getRatio(targetSize: targetSize)
        
        let newImage = getResizedImage(ratio: ratio)
        return ImageData(image: newImage, ratio: ratio)
    }
    
    func getRatio(targetSize: CGSize) -> CGFloat {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        let ratio = min(widthRatio, heightRatio)
        return ratio
    }
    
    
    
    private func getResizedImage(ratio: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        return autoreleasepool { () -> UIImage in
            UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
            draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? self
        }
    }
}
