//
//  GetMoviesSearchRequest.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 12.12.2020.
//

import Foundation

final class GetMoviesSearchRequest: BasicRequest {
    
    init(baseURL: String, query: String, page: Int, includeAdult: Bool) {
        super.init(
            baseURL: baseURL,
            endpointString: APIEndpoint.searchMovies(query: query, page: page, includeAdult: includeAdult).stringValue)
    }
}
