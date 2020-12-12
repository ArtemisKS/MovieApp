//
//  MovieService.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Alamofire

protocol GetMoviesReqDataProtocol {
    var page: Int { get }
    var query: String? { get }
    var includeAdult: Bool { get }
}

struct GetMoviesReqData: GetMoviesReqDataProtocol {
    let page: Int
    let query: String?
    var includeAdult: Bool = false
}

protocol MovieServiceProtocol {
    
    var baseURL: String { get }
    var apiManager: APIManagerProtocol { get }
    
    typealias GetMoviesResult = ResultError<MoviesModel, Error>
    typealias GetMovieDetailResult = ResultError<MovieDetail, Error>
    
    typealias GetMoviesCompletion = (GetMoviesResult) -> Void
    typealias GetMovieDetailCompletion = (GetMovieDetailResult) -> Void
    
    func getMovieDetails(
        id: String,
        completion: @escaping GetMovieDetailCompletion)
    
    func getMovies(
        with reqData: GetMoviesReqDataProtocol,
        completion: @escaping GetMoviesCompletion)
    
    func getMoviesSearch(
        with reqData: GetMoviesReqData,
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
        
        guard Utils.internetConnectionOK else {
            completion(
                .failure(
                    BasicError.withMessage("You appear to be offline")))
            return
        }
        
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
    
    func getMovieDetails(id: String, completion: @escaping GetMovieDetailCompletion) {
        
        let request = GetMovieDetailRequest(baseURL: baseURL, id: id)
        
        processGetRequest(
            request: request,
            respType: MovieDetail.self,
            completion: completion)
    }
    
    func getMovies(
        with reqData: GetMoviesReqDataProtocol,
        completion: @escaping GetMoviesCompletion) {
        
        let request = GetMoviesRequest(baseURL: baseURL, page: reqData.page)
        
        processGetRequest(
            request: request,
            respType: MoviesModel.self,
            completion: completion)
    }
    
    func getMoviesSearch(
        with reqData: GetMoviesReqData,
        completion: @escaping GetMoviesCompletion) {
        
        let request = GetMoviesSearchRequest(
            baseURL: baseURL,
            query: reqData.query ?? "",
            page: reqData.page,
            includeAdult: reqData.includeAdult)
        
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
