//
//  MovieTableViewCell.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

protocol ImageViewCell {
    var cellImageView: UIImageView { get }
    func setImage(_ image: UIImage)
    func setLoading(_ loading: Bool)
}

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension MovieTableViewCell: ImageViewCell {
    var cellImageView: UIImageView {
        posterImageView
    }
    
    func setLoading(_ loading: Bool) {
        let startLoading = loading && cellImageView.image == nil
        cellImageView.isHidden = startLoading
        startLoading ?
            activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func setImage(_ image: UIImage) {
        setLoading(false)
        posterImageView.image = image
    }
}

// MARK: - CellDesignable
extension MovieTableViewCell: CellDesignable {
    
    @discardableResult func configure(with model: CellModeling) -> Self {
        guard let cellModel = model as? MovieTableCellModel else { return self }
        titleLabel.text = cellModel.title
        return self
    }
    
}
