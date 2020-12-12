//
//  APIEndpoint.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

enum APIEndpoint {
    
    case getMovies(page: Int)
    case getMovieDetails(id: String)
    case searchMovies(query: String, page: Int, includeAdult: Bool)
    
    var stringValue: String {
        switch self {
        case .getMovies(let page):
            return "/movie/popular?api_key=\(Globals.apiKey)&language=en-US&page=\(page)"
        case .getMovieDetails(let id):
            return "/movie/\(id)?api_key=\(Globals.apiKey)&language=en-US"
        case .searchMovies(let query, let page, let includeAdult):
            return "/search/movie?api_key=\(Globals.apiKey)&language=en-US&query=\(query)&page=\(page)&include_adult=\(includeAdult)"
        }
    }
}
