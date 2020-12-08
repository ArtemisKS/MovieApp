//
//  LoaderTableViewCell.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

class LoaderTableViewCell: UITableViewCell {

    @IBOutlet weak var loaderSpinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loaderSpinner.startAnimating()
    }
    
    func setLoader(animating: Bool) {
        if animating {
            loaderSpinner.startAnimating()
        } else {
            loaderSpinner.stopAnimating()
        }
    }

    @discardableResult
    func config() -> LoaderTableViewCell {
        loaderSpinner.startAnimating()
        return self
    }
}

// MARK: - CellDesignable
extension LoaderTableViewCell: CellDesignable {
    
    @discardableResult func configure(with model: CellModeling) -> Self {
        guard let _ = model as? MovieTableCellModel else { return self }
        loaderSpinner.startAnimating()
        return self
    }
    
}
