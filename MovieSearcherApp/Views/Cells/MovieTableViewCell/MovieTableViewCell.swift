//
//  MovieTableViewCell.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

protocol ImageViewCell {
    var cellImageView: UIImageView { get }
}

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
}

// MARK: - CellDesignable
extension MovieTableViewCell: CellDesignable {
    
    @discardableResult func configure(with model: CellModeling) -> Self {
        guard let cellModel = model as? MovieTableCellModel else { return self }
        titleLabel.text = cellModel.title
        return self
    }
    
}
