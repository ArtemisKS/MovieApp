//
//  MainViewController+UISearchDelegate.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 09.12.2020.
//

import UIKit

extension MainViewController {
    
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
        
        footerResLabel.isHidden = hidden
        footerResLabel.text = count == 0 ?
            "No movies found" : "Found: \(count) movies"
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            clearAndResign(searchBar)
        } else {
            filterSearchResults(from: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
