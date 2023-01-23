//
//  ApiManager.swift
//  PopularFilms
//
//  Created by Alex Pirog on 19.01.2023.
//

import Foundation
import Combine
import Alamofire
import Kingfisher

class ApiManager {
    static var isReachable: Bool {
        NetworkReachabilityManager.default?.isReachable ?? false
    }
    
    // MARK: - Fetching
    
    static private let apiKey = Secrets.apiKey
    static private let baseUrl = "https://api.themoviedb.org/3/"
    
    static private func fetch<T: Decodable>(_ path: String, params additionalParams: [String: Any] = [:], of type: T.Type = T.self) -> DataResponsePublisher<T> {
        let url = baseUrl + path
        var params: [String: Any] = ["api_key": apiKey]
        params.merge(additionalParams, uniquingKeysWith: { _, _ in })
        let request = AF.request(url, parameters: params)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return request.publishDecodable(type: type, decoder: decoder)
    }
    
    static func discoverFilms(with option: SortOption, page: Int) -> DataResponsePublisher<FilmsResult> {
        // https://developers.themoviedb.org/3/discover/movie-discover
        fetch("discover/movie", params: ["sort_by": option.asApiParameter,
                                         "page": page])
    }
    
    static func searchFilms(query: String, page: Int) -> DataResponsePublisher<FilmsResult> {
        // https://developers.themoviedb.org/3/search/search-movies
        fetch("search/movie", params: ["query": query,
                                       "page": page])
    }
    
    static func getVideos(by filmId: Int) -> DataResponsePublisher<VideoResult> {
        // https://developers.themoviedb.org/3/movies/get-movie-videos
        fetch("movie/\(filmId)/videos")
    }
    
    static func fetchGenres() -> DataResponsePublisher<GenresResult> {
        // https://developers.themoviedb.org/3/genres/get-movie-list
        fetch("genre/movie/list")
    }
    
    // MARK: - Images
    
    enum FilmBackdropSize: String {
        case w300, w780, w1280, original
    }
    
    enum FilmPosterSize: String {
        case w92, w154, w185, w342, w500, w780, original
    }
    
    static private let imageBase = "https://image.tmdb.org/t/p/"
    
    static func getBackdropImageURL(for imagePath: String?, size: FilmBackdropSize) -> URL? {
        guard let path = imagePath else { return nil }
        return URL(string: imageBase + "\(size.rawValue)/" + path)
    }
    
    static func getPosterImageURL(for imagePath: String?, size: FilmPosterSize) -> URL? {
        guard let path = imagePath else { return nil }
        return URL(string: imageBase + "\(size.rawValue)/" + path)
    }
}
