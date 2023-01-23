//
//  Sort.swift
//  PopularFilms
//
//  Created by Alex Pirog on 19.01.2023.
//

import Foundation

struct SortOption {
    let name: String
    let parameter: SortParameter
    let order: SortOrder
    
    init(_ name: String, parameter: SortParameter, order: SortOrder) {
        self.name = name
        self.parameter = parameter
        self.order = order
    }
    
    var asApiParameter: String { "\(parameter.rawValue).\(order.rawValue)" }
}

enum SortOrder: String {
    case ascending = "asc"
    case descending = "desc"
}

enum SortParameter: String, CaseIterable {
    case popularity = "popularity"
    case releaseDate = "release_date"
    case revenue = "revenue"
    case rating = "vote_average"
    
    /*
     Choose from one of the many available sort options from API:
     popularity.asc, popularity.desc,
     release_date.asc, release_date.desc,
     revenue.asc, revenue.desc,
     primary_release_date.asc, primary_release_date.desc,
     original_title.asc, original_title.desc,
     vote_average.asc, vote_average.desc,
     vote_count.asc, vote_count.desc
     */
}
