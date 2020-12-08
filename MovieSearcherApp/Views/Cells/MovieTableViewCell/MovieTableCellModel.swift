//
//  MovieTableCellModel.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import Foundation

class MovieTableCellModel: CellModeling {
    
    var cellClass: AnyClass
    var reuseIdentifier: String
    
    var title: String
    
    init(title: String) {
        
        self.title = title
        
        cellClass = MovieTableViewCell.self
        reuseIdentifier = String(describing: cellClass)
    }
}
