//
//  ImagesLoader.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import SDWebImage

extension CGSize {
    
    static func >(lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.width > rhs.width || lhs.height > rhs.height
    }
}

protocol ImageLoader: class {
    var imagesDict: [UInt64 : UIImage] { get set }
    func fetchIcon(for cell: ImageViewCell, movie: MovieModel)
    
    func clearImagesDict()
}

extension ImageLoader {
    
    private func resizeImageIfNeeded(
        _ image: UIImage,
        key: UInt64,
        completion: (URL?) -> Void) {
        
        let maxWidth = 480
        let maxHeight = 640
        let targetSize = CGSize(width: maxWidth, height: maxHeight)
        let imData = image.resizeImage(targetSize: targetSize)
        let newImage = imData?.image ?? image
        let name = getImageFilename(from: key)
        let url = Utils.saveImage(image: newImage, to: name)
        imagesDict[key] = newImage
        completion(url)
    }
    
    // MARK: - images local storage, which works, but with memory leaks when converting uiimage to data, so laid off for now
    
    private func saveImage(_ image: UIImage, by key: UInt64) {
//        DispatchQueue.global().async {
//            self.resizeImageIfNeeded(image, key: key) { (url) in
//                if let url = url {
//                    debugPrint("URL: \(url)")
//                }
//            }
//        }
        imagesDict[key] = image
    }
    
    private func getImageFilename(from key: UInt64) -> String {
        "imageFile#\(key)"
    }
    
    private func saveImageData(_ data: Data?, key: UInt64) {
        if let data = data {
            let filename = getImageFilename(from: key)
            Utils.saveData(data, to: filename)
        }
    }
    
    private func getImageFromFile(by key: UInt64) -> UIImage? {
        
        // Doesn't work for now, as offline image storing is not used
//        let filename = getImageFilename(from: key)
//        if let data = Utils.getData(from: filename),
//           let image = UIImage(data: data) {
//            return image
//        }
        return nil
    }
    
    func fetchIcon(for cell: ImageViewCell, movie: MovieModel) {
        
        let key = movie.id
        if let image = imagesDict[key] {
            cell.setImage(image)
            return
        }
        
        guard let posterPath = movie.poster_path else {
            setDefImageToDict(cell: cell, key: key)
            return
        }
        let url = "\(Globals.posterBaseURL)\(posterPath)"
        cell.cellImageView.sd_setImage(with: URL(string: url)) { [weak self] (image, err, _, _) in
            guard let self = self else { return }
            if let image = image,
               err == nil {
                cell.setImage(image)
                self.saveImage(image, by: key)
            } else {
                self.setPlaceholderImage(for: cell, key: key)
            }
        }
        cell.setLoading(true)
    }
    
    private func setDefImageToDict(cell: ImageViewCell, key: UInt64) {
        var poster: UIImage
        let placeholder: UIImage = .getImage(for: .moviePosterPlaceholder)
        if let image = getImageFromFile(by: key) {
            poster = image
        } else {
            poster = placeholder
        }
//        imagesDict[key] = poster
        cell.setImage(poster)
    }
    
    private func setPlaceholderImage(
        for cell: ImageViewCell,
        key: UInt64) {
        
        setDefImageToDict(cell: cell, key: key)
    }
    
    func clearImagesDict() {
        imagesDict.removeAll()
    }
}

