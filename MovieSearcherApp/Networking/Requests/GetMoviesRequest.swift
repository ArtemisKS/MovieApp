//
//  GetMoviesRequest.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Foundation

final class GetMoviesRequest: BasicRequest {
    
    init(baseURL: String, page: Int) {
        super.init(
            baseURL: baseURL,
            endpointString: APIEndpoint.getMovies(page: page).stringValue)
    }
}
