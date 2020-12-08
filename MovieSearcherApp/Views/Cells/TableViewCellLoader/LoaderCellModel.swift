//
//  LoaderCellModel.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import Foundation

class LoaderTableCellModel: CellModeling {
    
    var cellClass: AnyClass
    var reuseIdentifier: String
    
    init() {
        cellClass = LoaderTableViewCell.self
        reuseIdentifier = String(describing: cellClass)
    }
}
