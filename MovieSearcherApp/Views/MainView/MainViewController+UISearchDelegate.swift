//
//  MainViewController+UISearchDelegate.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 09.12.2020.
//

import UIKit

extension MainViewController {
    
    var noInternet: Bool {
        !Utils.internetConnectionOK
    }
    
    func filterSearchResults(from searchText: String) {
        presenter.processSearchText(searchText)
    }
    
    func clearAndResign(_ searchBar: UISearchBar) {
        
        presenter.clearAndResignSearch()
        if !searchBar.text!.isEmpty {
            searchBar.text = ""
        }
        searchBar.resignFirstResponder()
    }
    
    func updateSearchLabel(hidden: Bool, count: Int) {
        
        let moviesPerPage = 20
        let noInternet = self.noInternet
        let divRest = count % moviesPerPage
        let pageNum = count / moviesPerPage + (divRest > 0 ? 1 : 0)
        let localLabel = "Found: \(count) movies"
        let remoteSearchLabel = pageNum == 1 && divRest > 0 ?
            localLabel :
            (noInternet ?"Result page \(pageNum)" :
                "Page \(pageNum) of search result")
        footerResLabel.isHidden = hidden
        let labelText = count == 0 ?
            "No movies found" :
            (!presenter.localSearch ?
                remoteSearchLabel : localLabel)
        let attrText = NSMutableAttributedString(string: labelText)
        if noInternet {
            let offlineStr = NSAttributedString(string: " (offline search)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.customRed])
            attrText.append(offlineStr)
        }
        footerResLabel.attributedText = attrText
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        setSearchQuery(searchText.isEmpty ? nil : searchText)
        filterSearchResults(from: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setSearchQuery(nil)
        clearAndResign(searchBar)
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text,
           !searchText.isEmpty {
            filterSearchResults(from: searchText)
        }
    }
    
}
