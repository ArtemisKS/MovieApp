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
    
    @IBOutlet weak var revenueStack: UIStackView!
    @IBOutlet var bottomInfoLabels: [UILabel]!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var upperViewHeightConstr: NSLayoutConstraint!
    private var posterImage: UIImage?
    
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

extension DetailViewController: DetailViewProtocol {
    
    func setPoster(_ image: UIImage?) {
        posterImage = image
    }
    
    func updateView(with movie: MovieDetail?, error: Error?) {
        
        setupPosterImage(with: movie)
        
        guard let movie = movie else {
            if let error = error {
                // TODO: - show error
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
            let url = "\(Globals.posterBaseURL)\(movie.poster_path)"
            posterImageView.sd_setImage(with: URL(string: url))
        }
    }
    
    private func setGenresLabel(from genres: [MovieDetail.Genre]) {
        genreDescLabel.text = genres.enumerated().map {
            $0 == genres.count - 1 ? $1.name : "\($1.name), "
        }.joined()
    }
    
    private func setLanguages(_ label: UILabel, from langs: [MovieDetail.SpokenLanguage]) {
        label.text = langs.enumerated().map { $0 == langs.count - 1 ? $1.english_name : "\($1.english_name), "
        }.joined()
    }
    
    private func setRevenue(_ label: UILabel, revenue: UInt64) {
        guard revenue != 0 else { revenueStack.isHidden = true; return }
        revenueStack.isHidden = false
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        let formattedNumber = numberFormatter.string(from: NSNumber(value: revenue))
        label.text = formattedNumber
    }
    
    private func setBottomInfoLabels(from movie: MovieDetail) {
        for botLabel in BotLabels.allCases {
            guard let label = getBottomLabel(for: botLabel) else { continue }
            switch botLabel {
            case .date:
                label.text = movie.release_date
            case .revenue:
                setRevenue(label, revenue: movie.revenue)
            case .runtime:
                label.text = "\(movie.runtime) min"
            case .lang:
                setLanguages(label, from: movie.spoken_languages)
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
