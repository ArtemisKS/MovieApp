//
//  MainViewController+UITableView.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import UIKit

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.dataLoaded ? cellModels.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if presenter.dataLoaded {
            let cell = cellForRowAt(indexPath)
            if let ivCell = cell as? ImageViewCell {
                presenter.fetchIcon(for: ivCell, index: indexPath.row)
            }
            return cell
        }
        return tableView.dequeueReusableCell(ofType: LoaderTableViewCell.self, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.cellModels[indexPath.row].reuseIdentifier == String(describing: MovieTableViewCell.self) {
//            presenter.didSelectMoreButton()
        }
    }
}

//extension DetailViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return .leastNormalMagnitude
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 54
//    }
//
////    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
////        "\(section + 1)"
////    }
//
//    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//}
