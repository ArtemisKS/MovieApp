//
//  TableDesignable.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit

protocol TableDesignable: class {
    var tableView: UITableView! { get }
    var cellModels: [CellModeling] { get }
    
    func registerCellNibs()
    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell
    func heightForRowAt(_ indexPath: IndexPath) -> CGFloat
}

extension TableDesignable {
    
    func registerCellNibs() {
        cellModels.forEach {
            let nibName = String(describing: $0.cellClass)
            let cellNib = UINib(nibName: nibName, bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: nibName)
        }
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cellModel = cellModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.reuseIdentifier, for: indexPath)
        
        guard let tableViewCell = cell as? CellDesignable else { return UITableViewCell() }
        tableViewCell.configure(with: cellModel)
        
        return cell
    }
    
    func heightForRowAt(_ indexPath: IndexPath) -> CGFloat {
        let cellModel = cellModels[indexPath.row]
        
        return cellModel.rowHeight
    }
}

protocol CellDesignable {
    @discardableResult func configure(with model: CellModeling) -> Self
}

protocol CellModeling {
    var cellClass: AnyClass { get }
    
    var rowHeight: CGFloat { get }
    
    var isSelectable: Bool { get }
}

extension CellModeling {
    
    var reuseIdentifier: String {
        return String(describing: cellClass)
    }
    
    var rowHeight: CGFloat {
        UITableView.automaticDimension
    }
    
    var isSelectable: Bool {
        false
    }
}

