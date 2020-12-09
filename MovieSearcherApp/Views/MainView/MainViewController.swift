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
    func setLoading(loading: Bool)
}

class MainViewController: UIViewController, TableDesignable {
    
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    
    var presenter: MainViewPresenterProtocol!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    let footerResLabelHeight: CGFloat = 40
    
    private(set) lazy var footerResLabel: UILabel = {
        let footerLabel = UILabel(
            frame: CGRect(
                origin: .zero,
                size: .init(
                    width: view.frame.width,
                    height: footerResLabelHeight)))
        
        footerLabel.backgroundColor = .mainBlue
        footerLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 18)
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
        setNavBar(title: "TMDB")
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
        searchController.searchBar.returnKeyType = .done
    }
    
    private func hideBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc private func openSearchBar() {
        searchController.searchBar.becomeFirstResponder()
    }
    
    private func setNavBarRightButtonItem() {
        navigationItem.rightBarButtonItem = presenter.dataLoaded ?
            .init(barButtonSystemItem: .search, target: self, action: #selector(openSearchBar)) : nil
    }
    
    func setNavBar(title: String) {
        self.title = title
        setNavBarRightButtonItem()
    }
    
}

extension MainViewController: MainViewProtocol {
    
    private var sectionNum: Int { 0 }
    
    func setLoading(loading: Bool) {
        tableView.isHidden = loading
        loading ?
            activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func handleStateChange(_ state: ListState<CellModeling>) {
        tableView.tableFooterView = footerView
        setNavBarRightButtonItem()
        switch state {
        case let .initial(cellModels), let .updated(cellModels):
            self.cellModels = cellModels
            self.tableView.performBatchUpdates({
                self.tableView.reloadSections([self.sectionNum], with: .none)
            }, completion: { [weak self] _ in
                self?.tableView.setContentOffset(.zero, animated: false)
            })
        case .loading:
            setLoading(loading: true)
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
    
    // MARK: - view setup methods
    
    func setupTableView() {
        tableView.backgroundColor = .systemWhite
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        //        tableView.bounces = false
        //        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = true
        tableView.tableFooterView = footerView
    }
}
