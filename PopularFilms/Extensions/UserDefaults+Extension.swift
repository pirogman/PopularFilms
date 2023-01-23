//
//  UserDefaults+Extension.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import Foundation

fileprivate let storedGenresKey = "StoredGenres"

extension UserDefaults {
    var storedGenresResult: GenresResult? {
        get {
            if let data = self.value(forKey: storedGenresKey) as? Data {
                 return try? JSONDecoder().decode(GenresResult.self, from: data)
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue, let data = try? JSONEncoder().encode(newValue) {
                self.set(data, forKey: storedGenresKey)
            } else {
                self.removeObject(forKey: storedGenresKey)
            }
        }
    }
}
