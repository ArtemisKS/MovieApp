//
//  MainViewController+UITableView.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        guard !presenter.isSearchOngoing &&
                !cellModels.isEmpty &&
                indexPath.row == cellModels.count - 1 else { return }
        showSpinner()
        presenter.onScrolledToBottom()
    }
    
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .customBlue
        spinner.frame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: 70)
        spinner.startAnimating()
        tableView.tableFooterView = spinner
    }
}
