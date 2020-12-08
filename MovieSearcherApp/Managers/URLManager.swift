//
//  URLManager.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Foundation

struct URLManager {
    
    static var baseURL: String {
        "https://api.themoviedb.org/3/movie"
    }
    
    static func getMovieUrl(with movieId: String) -> String {
        "https://api.themoviedb.org/3/movie/\(movieId))?api_key=\(Globals.apiKey)&language=en-US"
    }
}
