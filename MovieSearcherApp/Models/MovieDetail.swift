//
//  MovieDetail.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 08.12.2020.
//

import Foundation

struct MovieDetail: Codable {
    
    struct Collection: Codable {
        let id: UInt64
        let name: String
        let poster_path: String?
        let backdrop_path: String?
    }
    
    struct Genre: Codable {
        let id: UInt64
        let name: String
    }
    
    struct ProductionCompany: Codable {
        let id: UInt64
        let logo_path: String?
        let name: String
        let origin_country: String
    }
    
    struct ProductionCountry: Codable {
        let iso_3166_1: String
        let name: String
    }
    
    struct SpokenLanguage: Codable {
        let english_name: String
        let iso_639_1: String
        let name: String
    }
    
    let adult: Bool
    let backdrop_path: String?
    let belongs_to_collection: Collection?
    let budget: UInt64
    let genres: [Genre]
    let homepage: String?
    let id: UInt64
    let imdb_id: String?
    let original_language: String
    let original_title: String
    let overview: String
    let popularity: Double
    let poster_path: String?
    let production_companies: [ProductionCompany]
    let production_countries: [ProductionCountry]
    let release_date: String
    let revenue: UInt64
    let runtime: UInt32?
    let spoken_languages: [SpokenLanguage]
    let status: String
    let tagline: String
    let title: String
    let video: Bool
    let vote_average: Double
    let vote_count: UInt64
    
}
