//
//  Film.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import Foundation

struct FilmsResult: Decodable {
    let page: Int
    let results: [Film]
    let totalPages: Int
    let totalResults: Int
}

struct Film: Identifiable, Decodable {
    let id: Int
    let title: String
    let releaseDate: String?
    let overview: String
    let popularity: Double
    let adult: Bool
    let backdropPath: String?
    let posterPath: String?
    let genreIds: [Int]
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
}
