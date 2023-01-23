//
//  Genre.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import Foundation

struct GenresResult: Codable {
    let genres: [Genre]
}

struct Genre: Codable {
    let id: Int
    let name: String
}
