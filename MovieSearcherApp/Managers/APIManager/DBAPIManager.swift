//
//  DBAPIManager.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Alamofire
import SwiftyJSON

struct APIManagerValidStatusCodes {
    
    enum StatusCode {
        
        static var `default`: StatusCode { .range(200..<300) }
        
        case single(Int)
        case range(Range<Int>)
        case all
        
        func contains(_ statusCode: Int) -> Bool {
            switch self {
            case .range(let value): return value.contains(statusCode)
            case .single(let value): return value == statusCode
            case .all: return true
            }
        }
        
    }
    
    static var all: APIManagerValidStatusCodes { .init([.all]) }
    
    static var `default`: APIManagerValidStatusCodes { .init([.default]) }
    
    static func `default`(with statusCodes: [StatusCode]) -> APIManagerValidStatusCodes {
        .init([.default] + statusCodes)
    }
    
    static func `default`(with statusCode: StatusCode) -> APIManagerValidStatusCodes {
        .init([.default, statusCode])
    }
    
    let statusCodes: [StatusCode]
    
    init(_ statusCodes: [StatusCode]) {
        self.statusCodes = statusCodes
    }
    
}

class ReqValidError: NSObject, LocalizedError {
    let statusCode: Int
    let message: String?
    
    override var description: String {
        message ?? "Error with code \(statusCode)"
    }
    
    var errorDescription: String? {
        description
    }
    
    init(statusCode: Int, message: String?) {
        self.statusCode = statusCode
        self.message = message
    }
}


extension DataRequest {
    
    func validate(statusCodes: APIManagerValidStatusCodes) -> Self {
        validate { (_, response, data) -> Request.ValidationResult in
            if statusCodes.statusCodes.first(where: { $0.contains(response.statusCode) }) == nil {
                return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode)))
            } else {
                return .success(())
            }
        }
    }
    
}
