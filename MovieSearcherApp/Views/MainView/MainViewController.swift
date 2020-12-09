//
//  MainViewController.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Foundation
import UIKit

protocol MainViewProtocol: class {
    
    func handleStateChange(_ state: ListState<CellModeling>)
    func updateSearchLabel(hidden: Bool, count: Int)
}

class MainViewController: UIViewController, TableDesignable {
    
    @IBOutlet private(set) weak var tableView: UITableView!
    
    var presenter: MainViewPresenterProtocol!
    
    private var searchBar: UISearchBar!
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let footerResLabelHeight: CGFloat = 40
    
    private lazy var footerResLabel: UILabel = {
        let footerLabel = UILabel(
            frame: CGRect(
                origin: .zero,
                size: .init(
                    width: view.frame.width,
                    height: footerResLabelHeight)))
        
        footerLabel.backgroundColor = .mainBlue
        footerLabel.font = UIFont.systemFont(ofSize: 17)
        footerLabel.textAlignment = .center
        footerLabel.textColor = UIColor.systemWhite
        footerLabel.isHidden = true
        view.addSubview(footerLabel)
        return footerLabel
    }()
    
    private(set) lazy var footerView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 60))
    }()
    
    var cellModels: [CellModeling] = [] {
        didSet {
            registerCellNibs()
        }
    }
    
    var loadingTableViewHeight: CGFloat {
        let viewHeight = view.frame.height
        let screenHeight = UIScreen.main.bounds.height
        let height = min(viewHeight, screenHeight)
        return height -
            (navigationController?.navigationBar.frame.height ?? 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter?.onViewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      addKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      
      removeObservers()
    }
    
    private func setupView() {
        setupSearchBar()
        setupTableView()
        registerLoaderCell()
        hideBackButton()
        setNavBarTitle("TMDB")
    }
    
    private func registerLoaderCell() {
        tableView.register(cellType: LoaderTableViewCell.self)
    }
    
    private func setupSearchBar() {
        
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.clearButtonMode = .whileEditing
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search movies"
    }
    
    private func hideBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setNavBarTitle(_ title: String) {
        self.title = title
    }
    
}

extension MainViewController: MainViewProtocol {
    
    private var sectionNum: Int { 0 }
    
    func handleStateChange(_ state: ListState<CellModeling>) {
        tableView.tableFooterView = footerView
        switch state {
        case let .initial(cellModels), let .updated(cellModels):
            self.cellModels = cellModels
            self.updateRowHeight()
            //            UIView.animate(withDuration: 0.25, animations: {
            //                self.tableView.alpha = 1
            //            }) { _ in
            //
            //            }
            self.tableView.performBatchUpdates({
                self.tableView.reloadSections([self.sectionNum], with: .none)
            }, completion: { [weak self] _ in
                self?.tableView.setContentOffset(.zero, animated: false)
            })
        case .loading:
            self.updateRowHeight(loading: true)
        case let .error(error):
            break
        case let .loadedMore(cellModels):
            let startIndPath = self.cellModels.count - 1
            self.cellModels.append(contentsOf: cellModels)
            let indexPaths: [IndexPath] = cellModels.enumerated().map { ind, _ in IndexPath(row: startIndPath + ind, section: self.sectionNum) }
            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            })
        }
    }
    
}

private extension MainViewController {
    
    var bottomSafeArea: CGFloat {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    // MARK: - view setup methods
    
    func setupTableView() {
        tableView.backgroundColor = .systemWhite
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 300
        //        tableView.bounces = false
        //        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = true
        tableView.tableFooterView = footerView
        updateRowHeight()
    }
    
    func updateRowHeight() {
        updateRowHeight(loading: !presenter.dataLoaded)
    }
    
    func updateRowHeight(loading: Bool) {
        tableView.rowHeight = loading ?
            loadingTableViewHeight :
            UITableView.automaticDimension
    }
    
    func addKeyboardObservers() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showKeyboard(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideKeyboard(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc func showKeyboard(_ notification: Notification) {
        if let keyboardHeight = getKeyboardHeightFrom(notification) {
            
            footerResLabel.frame = getFooterLabelFrame(with: keyboardHeight)
        }
    }
    
    @objc func hideKeyboard(_ notification: Notification) {
        footerResLabel.frame = getFooterLabelFrame()
    }
}

extension MainViewController {
    
    func getKeyboardHeightFrom(_ notification: Notification) -> CGFloat? {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            return keyboardRectangle.height
        }
        return nil
    }
    
    func getFooterLabelFrame(with keyboardHeight: CGFloat? = nil) -> CGRect {
        
        let origin = CGPoint(
            x: 0,
            y: getFooterLabelY(with: keyboardHeight))
        
        let size = CGSize(
            width: view.frame.width,
            height: getFooterLabelHeight(with: keyboardHeight))
        
        return CGRect(origin: origin, size: size)
    }
    
    func getFooterLabelY(with keyboardHeight: CGFloat?) -> CGFloat {
        let val = keyboardHeight ?? bottomSafeArea
        return view.frame.height - footerResLabelHeight
            - val
    }
    
    func getFooterLabelHeight(with keyboardHeight: CGFloat?) -> CGFloat {
        let val = keyboardHeight != nil ?
            footerResLabelHeight : footerResLabelHeight + bottomSafeArea
        return val
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
