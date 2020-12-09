//
//  DetailViewController.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit
import SDWebImage
import UICircularProgressRing

class DetailViewController: UIViewController {
    
    @IBOutlet weak var contScrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingsView: UICircularProgressRing!
    @IBOutlet weak var genreDescLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewDescLabel: UILabel!
    @IBOutlet weak var bottomContView: UIView!
    
    @IBOutlet var bottomStackViews: [UIStackView]!
    @IBOutlet var bottomInfoLabels: [UILabel]!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var upperViewHeightConstr: NSLayoutConstraint!
    private var posterImage: UIImage?
    
    private lazy var errorView: UIView = {
        
        let title = UILabel()
        title.text = "Sorry, an error occured"
        title.font = .systemFont(ofSize: 17, weight: .bold)
        title.numberOfLines = 0
        title.sizeToFit()
        
        let subtitle = UILabel()
        subtitle.text = "Could not load the data for movie '\(presenter.movieData.title)'"
        subtitle.font = .systemFont(ofSize: 12)
        subtitle.textColor = .init(red: 0.337, green: 0.337, blue: 0.443, alpha: 1)
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center
        
        let sv = UIStackView(arrangedSubviews: [title, subtitle])
        sv.axis = .vertical
        sv.spacing = 8
        
        let container = UIView()
        container.backgroundColor = .white
        container.addSubview(sv)
        view.addSubview(container)
        
        for view in [container, sv] {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let leadAnchorConst: CGFloat = (view.frame.width - title.frame.width) / 2
        
        NSLayoutConstraint.activate([
            sv.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            sv.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            sv.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leadAnchorConst),
            sv.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -leadAnchorConst)
        ])
        
        return container
    }()
    
    private enum BotLabels: Int, CaseIterable {
        case date = 0
        case revenue = 1
        case runtime = 2
        case lang = 3
    }
    
    var presenter: DetailViewPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter?.onViewLoaded()
        setNavBarTitle("Movie detail")
        scrollView.delegate = self
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)
      
        bottomContView.backgroundColor = isDarkMode ?
        UIColor.mainBlue.withAlphaComponent(0.4) :
        UIColor.mainBlue.withAlphaComponent(0.2)
    }
    
    private func setupView() {
        contScrollView.bounces = false
        upperViewHeightConstr.constant = view.safeAreaInsets.top
    }
    
    private func setNavBarTitle(_ title: String) {
        self.title = title
    }
    
//    @IBAction func buttonTapped(_ sender: UIButton) {
//        presenter.tapOnData()
//    }
    
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
    
    private func setupNoOperViewConstr(_ container: UIView) {
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func updateView(with movie: MovieDetail?, error: Error?) {
        
        setupPosterImage(with: movie)
        
        guard let movie = movie else {
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, completion:  { [weak self] in
                    guard let self = self else { return }
                    self.activityIndicator.stopAnimating()
                    self.errorView.isHidden = false
                    self.setupNoOperViewConstr(self.errorView)
                })
            }
            return
        }
        
        activityIndicator.stopAnimating()
        
        setGenresLabel(from: movie.genres)
        titleLabel.text = movie.original_title
        overviewDescLabel.text = movie.overview
        setBottomInfoLabels(from: movie)
        
        contScrollView.isHidden = false
        
        setNavBarTitle(movie.title)
        
        animateRatingsView(rating: movie.vote_average)
    }
    
    private func setupPosterImage(with movie: MovieDetail?) {
        posterImageView.image = posterImage
        if let movie = movie,
           posterImage == nil {
            guard let posterPath = movie.poster_path else {
                posterImageView.image = .getImage(for: .moviePosterPlaceholder)
                return
            }
            let url = "\(Globals.posterBaseURL)\(posterPath)"
            posterImageView.sd_setImage(with: URL(string: url))
        }
    }
    
    private func setGenresLabel(from genres: [MovieDetail.Genre]) {
        genreDescLabel.text = genres.enumerated().map {
            $0 == genres.count - 1 ? $1.name : "\($1.name), "
        }.joined()
    }
    
    private func setLanguages(_ label: UILabel, index: Int, from langs: [MovieDetail.SpokenLanguage]) {
        let text = langs.enumerated().map { $0 == langs.count - 1 ? $1.english_name : "\($1.english_name), "
        }.joined()
        label.text = text
        bottomStackViews[index].isHidden = text.isEmpty
    }
    
    private func setRevenue(_ label: UILabel, index: Int, revenue: UInt64) {
        guard revenue != 0 else {
            bottomStackViews[index].isHidden = true
            return
        }
        bottomStackViews[index].isHidden = false
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        let formattedNumber = numberFormatter.string(from: NSNumber(value: revenue))
        label.text = formattedNumber
    }
    
    private func setBottomInfoLabels(from movie: MovieDetail) {
        for botLabel in BotLabels.allCases {
            let index = botLabel.rawValue
            guard let label = getBottomLabel(for: botLabel) else { continue }
            switch botLabel {
            case .date:
                label.text = movie.release_date
            case .revenue:
                setRevenue(label, index: index, revenue: movie.revenue)
            case .runtime:
                label.text = "\(movie.runtime) min"
                bottomStackViews[index].isHidden = movie.runtime == 0
            case .lang:
                setLanguages(label, index: index, from: movie.spoken_languages)
            }
        }
    }
    
    private func getBottomLabel(for label: BotLabels) -> UILabel? {
        bottomInfoLabels.first { $0.tag == label.rawValue }
    }
    
    private func animateRatingsView(rating: Double) {
        let level = CGFloat(rating * 10)
        ratingsView.innerRingColor = .mainBlue
        ratingsView.font = .systemFont(ofSize: 15)
        ratingsView.startProgress(to: level, duration: 1)
    }
}
