//
//  DetailViewModel.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 10.12.2020.
//

import UIKit

protocol DetailViewModelProtocol {
    
    var genresLabelText: String { get }
    var languageText: String { get }
    var revenueText: String? { get }
    var releaseDateText: String { get }
    var runtimeText: String { get }
    var titleText: String { get }
    var overviewText: String { get }
    var navBarTitle: String { get }
    
    var isLangHidden: Bool { get }
    var isRevenueHidden: Bool { get }
    var isRuntimeHidden: Bool { get }
    var isRatingsHidden: Bool { get }
    
    var posterPath: String? { get }
    
    var ratingsLevel: CGFloat { get }
}

struct DetailViewModel: DetailViewModelProtocol {
    
    private var movie: MovieDetail
    
    var posterPath: String? {
        movie.poster_path
    }
    
    var genresLabelText: String {
        let genres = movie.genres
        return genres.enumerated().map {
            $0 == genres.count - 1 ? $1.name : "\($1.name), "
        }.joined()
    }
    
    var languageText: String {
        let langs = movie.spoken_languages
        return langs.enumerated().map { $0 == langs.count - 1 ? $1.english_name : "\($1.english_name), "
        }.joined()
    }
    
    var revenueText: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        let formattedNumber = numberFormatter.string(from: NSNumber(value: movie.revenue))
        return formattedNumber
    }
    
    var releaseDateText: String {
        movie.release_date
    }
    
    var runtimeText: String {
        "\(movie.runtime) min"
    }
    
    var titleText: String {
        movie.original_title
    }
    
    var overviewText: String {
        movie.overview
    }
    
    var navBarTitle: String {
        movie.title
    }
    
    var isLangHidden: Bool {
        languageText.isEmpty
    }
    
    var isRevenueHidden: Bool {
        movie.revenue == 0
    }
    
    var isRuntimeHidden: Bool {
        movie.runtime == 0
    }
    
    var isRatingsHidden: Bool {
        ratingsLevel == 0
    }
    
    var ratingsLevel: CGFloat {
        CGFloat(movie.vote_average * 10)
    }
    
    init?(movie: MovieDetail?) {
        if let movie = movie {
            self.movie = movie
        } else {
            return nil
        }
    }
}
