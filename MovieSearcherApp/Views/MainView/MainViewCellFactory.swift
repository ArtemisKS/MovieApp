//
//  MainViewCellFactory.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

//MARK: DBTransaction ViewController's cells methods

final class DBTransactionCellModelsFactory {
    
    func movieCellModel(title: String) -> MovieTableCellModel {
        .init(title: title)
    }
}
