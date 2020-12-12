//
//  DetailViewController.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit
import SDWebImage
import UICircularProgressRing

protocol ErrorViewTexting {
    var titleText: String { get }
    var subtitleText: String { get }
    var buttonText: String { get }
}

class ErrorViewVC: UIViewController, ErrorViewTexting {
    
    var titleText: String { "Error" }
    
    var subtitleText: String { "An error occured" }
    
    var buttonText: String { "Try again" }
    
    lazy var errorView: UIView = {
        
        let title = UILabel()
        title.text = titleText
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 17, weight: .bold)
        title.numberOfLines = 0
        title.sizeToFit()
        
        let subtitle = UILabel()
        subtitle.text = subtitleText
        subtitle.font = .systemFont(ofSize: 13)
        subtitle.textColor = .init(red: 0.337, green: 0.337, blue: 0.443, alpha: 1)
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center
        
        let button = UIButton(type: .system)
        button.setCornerRadius()
        button.tintColor = .systemWhite
        button.backgroundColor = .customBlue
        button.setTitle(buttonText, for: .normal)
        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        
        let buttonSV = UIStackView(arrangedSubviews: [UIView(), button])
        buttonSV.axis = .vertical
        buttonSV.spacing = 16
        
        let sv = UIStackView(arrangedSubviews: [title, subtitle, buttonSV])
        sv.axis = .vertical
        sv.spacing = 8
        
        let container = UIView()
        container.backgroundColor = .systemWhite
        container.addSubview(sv)
        view.addSubview(container)
        
        for view in [container, sv, button] {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        var leadAnchorConst: CGFloat = (view.frame.width - title.frame.width) / 2
        if leadAnchorConst > view.frame.width / 4 {
            leadAnchorConst /= 2
        }
        
        NSLayoutConstraint.activate([
            sv.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            sv.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            sv.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leadAnchorConst),
            sv.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -leadAnchorConst),
            button.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        return container
    }()
    
    func setupNoOperViewConstr(_ container: UIView) {
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc func onButtonTapped() {}
}

class DetailViewController: ErrorViewVC {
    
    @IBOutlet weak var contScrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingsView: UICircularProgressRing!
    @IBOutlet weak var genreDescLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewDescLabel: UILabel!
    @IBOutlet weak var bottomContView: UIView!
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet var bottomStackViews: [UIStackView]!
    @IBOutlet var bottomInfoLabels: [UILabel]!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var upperViewHeightConstr: NSLayoutConstraint!
    private var posterImage: UIImage?
    
    override var titleText: String { "An error occured" }
    
    override var subtitleText: String { "Could not load the data for movie '\(presenter.movieData.title)'" }
    
    enum BotLabels: Int, CaseIterable {
        case date = 0
        case revenue = 1
        case runtime = 2
        case lang = 3
    }
    
    private(set) var presenter: DetailViewPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setNavBarTitle("Movie detail")
        scrollView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter?.onViewLoaded()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)
        
        for case let view? in [topStackView, bottomContView] {
            view.backgroundColor = isDarkMode ?
                UIColor.mainBlue.withAlphaComponent(0.4) :
                UIColor.mainBlue.withAlphaComponent(0.2)
        }
    }
    
    private func setupView() {
        contScrollView.bounces = false
        upperViewHeightConstr.constant = view.safeAreaInsets.top
    }
    
    private func setNavBarTitle(_ title: String) {
        self.title = title
    }
    
    @objc override func onButtonTapped() {
        presenter.onViewLoaded()
    }
    
    func setPresenter(_ presenter: DetailViewPresenterProtocol) {
        self.presenter = presenter
    }
    
}

extension DetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }
    }
}

extension DetailViewController: DetailViewProtocol {
    
    func setPoster(_ image: UIImage?) {
        posterImage = image
    }
    
    func setLoading(loading: Bool) {
        loading ?
            activityIndicator.startAnimating(): activityIndicator.stopAnimating()
        if loading {
            errorView.isHidden = true
            contScrollView.isHidden = true
        }
    }
    
    func updateView(with viewModel: DetailViewModelProtocol?, error: Error?) {
        
        setupPosterImage(with: viewModel)
        
        guard let viewModel = viewModel else {
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okAction: { [weak self] in
                    guard let self = self else { return }
                    self.setLoading(loading: false)
                    self.errorView.isHidden = false
                    self.setupNoOperViewConstr(self.errorView)
                })
            }
            return
        }
        
        setupBottomLabels(from: viewModel)
        
        showContent()
        
        setNavBarTitle(viewModel.navBarTitle)
        animateRatingsView(viewModel: viewModel)
    }
    
    private func showContent() {
        setLoading(loading: false)
        errorView.isHidden = true
        contScrollView.isHidden = false
    }
    
    private func setupBottomLabels(from viewModel: DetailViewModelProtocol) {
        genreDescLabel.text = viewModel.genresLabelText
        titleLabel.text = viewModel.titleText
        overviewDescLabel.text = viewModel.overviewText
        setBottomInfoLabels(from: viewModel)
    }
    
    private func setupPosterImage(with viewModel: DetailViewModelProtocol?) {
        posterImageView.image = posterImage
        if let viewModel = viewModel,
           posterImage == nil {
            guard let posterPath = viewModel.posterPath else {
                posterImageView.image = .getImage(for: .moviePosterPlaceholder)
                return
            }
            let url = "\(Globals.posterBaseURL)\(posterPath)"
            posterImageView.sd_setImage(with: URL(string: url))
        }
    }
    
    private func setBotLabel(_ label: UILabel, botLabel: BotLabels, from viewModel: DetailViewModelProtocol) {
        
        let index = botLabel.rawValue
        label.text = viewModel.getBottomLabelText(botLabel)
        bottomStackViews[index].isHidden = viewModel.isBottomLabelHidden(botLabel)
    }
    
    private func setBottomInfoLabels(from viewModel: DetailViewModelProtocol) {
        for botLabel in BotLabels.allCases {
            guard let label = getBottomLabel(for: botLabel) else { continue }
            setBotLabel(label, botLabel: botLabel, from: viewModel)
        }
    }
    
    private func getBottomLabel(for label: BotLabels) -> UILabel? {
        bottomInfoLabels.first { $0.tag == label.rawValue }
    }
    
    private func animateRatingsView(viewModel: DetailViewModelProtocol) {
        let level = viewModel.ratingsLevel
        let isHidden = viewModel.isRatingsHidden
        ratingsView.isHidden = isHidden
        if !isHidden {
            ratingsView.innerRingColor = .mainBlue
            ratingsView.font = .systemFont(ofSize: 15)
            ratingsView.startProgress(to: level, duration: 1)
        }
    }
}
