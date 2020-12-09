//
//  MovieModel.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Foundation

struct MovieModel: Codable {
    let adult: Bool
    let backdrop_path: String?
    let genre_ids: [Int]
    let id: UInt64
    let original_language: String
    let original_title: String
    let overview: String
    let popularity: Double
    let poster_path: String?
    let release_date: String?
    let title: String
    let video: Bool
    let vote_average: Double
    let vote_count: UInt64
}

struct MoviesModel: Codable {
    
    let results: [MovieModel]
    let page: Int
}
