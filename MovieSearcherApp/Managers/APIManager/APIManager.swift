//
//  APIManager.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Alamofire

enum Result<T> {
    case success(T)
    case failure(Error)
}

typealias APIManagerCallback = ((Result<Data>) -> Void)

protocol APIManagerProtocol {
    
    static var baseHeaders: HTTPHeaders { get }
    static var allHeaders: HTTPHeaders { get }
    
    func sendRequest(
        request: URLRequestConvertible,
        validStatusCodes: APIManagerValidStatusCodes,
        completion: @escaping APIManagerCallback)
}

fileprivate class MyServerTrustPolicyManager: ServerTrustManager {
    override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
        DisabledTrustEvaluator()
    }
}

final class APIManager: APIManagerProtocol {
    
    static var allHeaders: HTTPHeaders {
        var headers = baseHeaders
        headers["Content-Type"] = "application/json"
        return headers
    }
    
    static var baseHeaders: HTTPHeaders { [:] }
    
    private let manager: Alamofire.Session
    
    init() {
        self.manager = Alamofire.Session(serverTrustManager: MyServerTrustPolicyManager(evaluators: [:]))
    }
    
    func sendRequest(
        request: URLRequestConvertible,
        validStatusCodes: APIManagerValidStatusCodes = .default,
        completion: @escaping APIManagerCallback) {
        
        manager.request(request)
            .validate(statusCodes: validStatusCodes)
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { (dataResponse) in
                
                switch dataResponse.result {
                case .success(let JSON):
                    completion(.success(JSON))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        
    }
    
}
