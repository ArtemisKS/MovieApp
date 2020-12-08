//
//  MovieService.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Alamofire

protocol MovieServiceProtocol {
    
    var baseURL: String { get }
    var apiManager: APIManagerProtocol { get }
    
    typealias GetMoviesResult = ResultError<MoviesModel, Error>
    
    typealias GetMoviesCompletion = (GetMoviesResult) -> Void
    
    func getMovies(
        page: Int,
        completion: @escaping GetMoviesCompletion)
}

struct MovieService: MovieServiceProtocol {
    
    let baseURL: String
    let apiManager: APIManagerProtocol
    
    init(apiManager: APIManagerProtocol, baseURL: String) {
        
        self.apiManager = apiManager
        self.baseURL = baseURL
    }
    
    private func processGetRequest<T: BasicRequest, A: Decodable>(
        request: T,
        respType: A.Type,
        completion: @escaping (ResultError<A, Error>) -> Void) {
        
        apiManager.sendRequest(
            request: request,
            validStatusCodes: .default) { (result) in
            
            let completionResult: ResultError<A, Error>
            defer {
                DispatchQueue.main.async {
                    completion(completionResult)
                }
            }
            
            switch result {
            case .success(let data):
                let response: A
                do {
                    response = try JSONDecoder().decode(A.self, from: data)
                    completionResult = .success(response)
                } catch {
                    return completionResult = .failure(error)
                }
            case .failure(let error):
                completionResult = .failure( error)
            }
        }
    }
    
    func getMovies(
        page: Int,
        completion: @escaping GetMoviesCompletion) {
        
        let request = GetMoviesRequest(baseURL: baseURL, page: page)
        
        processGetRequest(
            request: request,
            respType: MoviesModel.self,
            completion: completion)
    }
}

enum ResultError<Data, Error> {
    case success(Data)
    case failure(Error)
}
