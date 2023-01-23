//
//  FilmDetailsVM.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import Foundation
import Combine

enum VideoState {
    case available(URL)
    case unavailable
    case loading
}

protocol FilmDetailsVMProtocol {
    var updateSubject: PassthroughSubject<Void, Never> { get }
    var errorSubject: PassthroughSubject<Error, Never> { get }
    var loadingSubject: CurrentValueSubject<Bool, Never> { get }
    
    var posterURL: URL? { get }
    var fullImageURL: URL? { get }
    var canViewPoster: Bool { get }
    var title: String { get }
    var releaseDate: String { get }
    var genres: [String] { get }
    var video: VideoState { get }
    var rating: Double { get }
    var description: String { get }
    
    func loadVideoLink()
}

final class FilmDetailsVM: FilmDetailsVMProtocol {
    var updateSubject = PassthroughSubject<Void, Never>()
    var errorSubject = PassthroughSubject<Error, Never>()
    var loadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    var posterURL: URL? {
        ApiManager.getPosterImageURL(for: film.posterPath, size: .w500)
    }
    var fullImageURL: URL? {
        ApiManager.getPosterImageURL(for: film.posterPath, size: .original)
    }
    var canViewPoster: Bool {
        posterURL != nil || fullImageURL != nil
    }
    var title: String { film.title }
    var releaseDate: String { film.releaseDate ?? "Unknown release data" }
    var genres: [String] {
        if let stored = UserDefaults.standard.storedGenresResult {
            // Use stored ones if available
            return film.genreIds.map { id in
                stored.genres.first { genre in
                    genre.id == id
                }?.name ?? String(id)
            }
        } else {
            // Initiate fetching if not already
            if genresCancellable == nil {
                loadingSubject.send(true)
                genresCancellable = ApiManager.fetchGenres()
                    .sink { [weak self] response in
                        guard let self = self else { return }
                        switch response.result {
                        case .failure(let error):
                            self.errorSubject.send(error)
                        case .success(let result):
                            UserDefaults.standard.storedGenresResult = result
                            self.updateSubject.send()
                        }
                        self.genresCancellable = nil
                        self.updateLoadingSubject()
                    }
            }
            
            // Provide something while loading
            return ["..."]
        }
    }
    var video: VideoState = .loading
    var rating: Double { film.voteAverage }
    var description: String { film.overview }
    
    private var videosCancellable: AnyCancellable?
    private var genresCancellable: AnyCancellable?
    
    let film: Film
    
    init(_ film: Film) {
        self.film = film
    }
    
    deinit {
        genresCancellable = nil
        videosCancellable = nil
    }
    
    func loadVideoLink() {
        guard videosCancellable == nil else { return }
        
        loadingSubject.send(true)
        videosCancellable = ApiManager.getVideos(by: film.id)
            .sink { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .failure(let error):
                    self.video = .unavailable
                    self.updateSubject.send()
                    
                    self.errorSubject.send(error)
                    debugPrint(error)
                case .success(let result):
                    if let last = result.results.last, last.site == "YouTube" {
                        let url = URL(string: "https://www.youtube.com/embed/\(last.key)")!
                        self.video = .available(url)
                        self.updateSubject.send()
                    } else {
                        self.video = .unavailable
                        self.updateSubject.send()
                    }
                }
                self.videosCancellable = nil
                self.updateLoadingSubject()
            }
    }
    
    private func updateLoadingSubject() {
        let loadsGenres = genresCancellable != nil
        let loadsVideos = videosCancellable != nil
        loadingSubject.send(loadsGenres || loadsVideos)
    }
}
