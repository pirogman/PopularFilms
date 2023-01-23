//
//  Foundation+Extensions.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import Foundation

extension Optional where Wrapped == String {
    var isEmptyOrNil: Bool { self?.isEmpty ?? true }
}
