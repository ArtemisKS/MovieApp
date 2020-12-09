//
//  BasicRequest.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Alamofire

class BasicRequest: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let requestStringUrl = baseURL + endpointString
        let requestUrl = try requestStringUrl.asURL()
        let request = try URLRequest(url: requestUrl, method: method, headers: APIManager.allHeaders)
        return request
    }
    
    private let baseURL: String
    private let method: HTTPMethod = .get
    private let endpointString: String
    
    init(baseURL: String, endpointString: String) {
        self.baseURL = baseURL
        self.endpointString = endpointString
    }
}
