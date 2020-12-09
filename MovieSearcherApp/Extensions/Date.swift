//
//  Date.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 09.12.2020.
//

import Foundation

extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    static func + (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate + rhs.timeIntervalSinceReferenceDate
    }
}
