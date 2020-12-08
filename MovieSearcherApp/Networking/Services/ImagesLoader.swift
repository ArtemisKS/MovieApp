//
//  ImagesLoader.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import SDWebImage

protocol ImageLoader: class {
    var imagesDict: [UInt64 : UIImage] { get set }
    func fetchIcon(for cell: ImageViewCell, movie: MovieModel)
    
    func clearImagesDict()
}

extension ImageLoader {
    
    func fetchIcon(for cell: ImageViewCell, movie: MovieModel) {
        
        let key = movie.id
        if let image = imagesDict[key] {
            cell.cellImageView.image = image
            return
        }
        
        let url = "\(Globals.posterBaseURL)\(movie.poster_path)"
        cell.cellImageView.sd_setImage(with: URL(string: url)) { (image, err, _, _) in
            if err == nil && image != nil {
                self.imagesDict[key] = image
            } else {
                self.setPlaceholderImage(for: cell, key: key)
            }
        }
    }
    
    private func setPlaceholderImage(
        for cell: ImageViewCell,
        key: UInt64) {
        
        if let icon = cell.cellImageView.image {
            self.imagesDict[key] = icon
        }
    }
    
    func clearImagesDict() {
        imagesDict.removeAll()
    }
}

