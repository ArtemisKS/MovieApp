//
//  DataStructs.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 09.12.2020.
//

import Foundation

enum ListState<T> {
    case loading
    case initial(items: [T])
    case loadedMore(items: [T])
    case updated(items: [T])
    case error(Error?)
}

class BasicError: NSObject, LocalizedError {
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
    
    class func withCode(_ code: Int) -> BasicError {
        BasicError(statusCode: code, message: nil)
    }
    
    class func withMessage(_ message: String) -> BasicError {
        BasicError(statusCode: -1, message: message)
    }
}
