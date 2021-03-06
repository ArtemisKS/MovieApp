//
//  MainViewController+UITableView.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    var footerResActualHeight: CGFloat {
        footerResLabel.isHidden ? 0 : footerResLabelHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellForRowAt(indexPath)
        if let ivCell = cell as? ImageViewCell {
            presenter.fetchIcon(for: ivCell, index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        if self.cellModels[index].reuseIdentifier == String(describing: MovieTableViewCell.self) {
            presenter.didTapOnCell(index: index)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !presenter.localSearch &&
                !cellModels.isEmpty &&
                indexPath.row == cellModels.count - 1 else { return }
        showSpinner()
        presenter.onScrolledToBottom(query: searchQuery)
    }
    
    
    private func showSpinner() {
        let height: CGFloat = 70 + footerResActualHeight
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .customBlue
        spinner.frame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: height)
        spinner.startAnimating()
        tableView.tableFooterView = spinner
    }
}
