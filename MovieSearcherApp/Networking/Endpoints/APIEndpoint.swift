//
//  APIEndpoint.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

enum APIEndpoint {
    
    case getMovies(page: Int)
    case getMovieDetails(id: String)
    
    var stringValue: String {
        switch self {
        case .getMovies(let page):
            return "/popular?api_key=\(Globals.apiKey)&language=en-US&page=\(page)"
        case .getMovieDetails(let id):
            return "/\(id)?api_key=\(Globals.apiKey)&language=en-US"
        }
    }
}
