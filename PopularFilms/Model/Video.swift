//
//  Video.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import Foundation

struct VideoResult: Decodable {
    let id: Int
    let results: [Video]
}

struct Video: Decodable {
    let id: String
    let name: String
    let key: String
    let site: String // Assume only YouTube?
}
