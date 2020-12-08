//
//  GetMovieDetailRequest.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import Foundation

final class GetMovieDetailRequest: BasicRequest {
    
    init(baseURL: String, id: String) {
        super.init(
            baseURL: baseURL,
            endpointString: APIEndpoint.getMovieDetails(id: id).stringValue)
    }
}
