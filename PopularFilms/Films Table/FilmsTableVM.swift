//
//  FilmsTableVM.swift
//  PopularFilms
//
//  Created by Alex Pirog on 19.01.2023.
//

import Foundation
import Combine

protocol FilmsTableVMProtocol {
    var tableReloadSubject: PassthroughSubject<Void, Never> { get }
    var errorSubject: PassthroughSubject<Error, Never> { get }
    var loadingSubject: CurrentValueSubject<Bool, Never> { get }
    
    var tableViewCount: Int { get }
    var sortOptions: [SortOption] { get }
    
    func reloadFilms()
    func paginateWhenSearch()
    func paginate(at prefetchedIndexPaths: [IndexPath])
    func getFilm(at indexPath: IndexPath) -> Film?
    func getFilmInfo(at indexPath: IndexPath) -> FilmInfo?
    
    func applySort(named: String)
    func applySearch(_ search: String?)
}

class FilmsTableVM: FilmsTableVMProtocol {
    var tableReloadSubject = PassthroughSubject<Void, Never>()
    var errorSubject = PassthroughSubject<Error, Never>()
    var loadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    var tableViewCount: Int {
        if nameFilter.isEmptyOrNil {
            // If no local filter - provide total possible results
            return totalResults
        } else if films.count < totalResults {
            // When filtering and can load more - add 10 for pagination
            return filteredFilms.count + 10
        } else {
            // Filter when ALL films loaded - just count
            return filteredFilms.count
        }
    }
    private(set) var totalResults = 0
    
    private var films = [Film]()
    private var currentPage = 0
    
    let sortOptions: [SortOption]
    private var currentOptionIndex = 0
    
    private var nameFilter: String?
    private var filteredFilms: [Film] {
        guard let nameFilter = nameFilter, !nameFilter.isEmpty else { return films }
        return films.filter { $0.title.contains(nameFilter) }
    }
    private var stopBizarrePagination = false
    
    private var loadCancellable: AnyCancellable?
    private var genresCancellable: AnyCancellable?
    
    init(sortOptions: [SortOption]) {
        self.sortOptions = sortOptions
    }
    
    deinit {
        loadCancellable = nil
        genresCancellable = nil
    }
    
    private func loadFilms() {
        guard loadCancellable == nil else { return }
        guard !stopBizarrePagination else { return }
        
        let loadPage = currentPage + 1
        loadingSubject.send(true)
        loadCancellable = ApiManager.discoverFilms(with: sortOptions[currentOptionIndex], page: loadPage)
            .sink { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .failure(let error):
                    self.errorSubject.send(error)
                case .success(let result):
                    self.currentPage = result.page
                    self.totalResults = result.totalResults
                    self.films += result.results
                    
                    // Stop pagination on bizarre filters
                    let availableResults = self.films.count
                    if self.filteredFilms.isEmpty && availableResults >= 300 {
                        print("Stop bizarre pagination")
                        self.totalResults = availableResults
                        self.stopBizarrePagination = true
                    }
                    
                    self.tableReloadSubject.send()
                }
                self.loadCancellable = nil
                self.loadingSubject.send(false)
            }
    }
    
    private func cancelLoad(clear: Bool) {
        loadCancellable?.cancel()
        loadCancellable = nil
        loadingSubject.send(false)
        
        if clear {
            totalResults = 0
            currentPage = 0
            films.removeAll()
            tableReloadSubject.send()
        }
    }
    
    func reloadFilms() {
        cancelLoad(clear: true)
        loadFilms()
    }
    
    func paginateWhenSearch() {
        loadFilms()
    }
    
    func paginate(at prefetchedIndexPaths: [IndexPath]) {
        guard loadCancellable == nil else { return }
        
        if nameFilter.isEmptyOrNil {
            if prefetchedIndexPaths.contains(where: { $0.row >= tableViewCount }) {
                loadFilms()
            }
        }
    }
    
    func getFilm(at indexPath: IndexPath) -> Film? {
        guard indexPath.row < filteredFilms.count else { return nil }
        return filteredFilms[indexPath.row]
    }
    
    func getFilmInfo(at indexPath: IndexPath) -> FilmInfo? {
        guard let film = getFilm(at: indexPath) else { return nil }
        let release = film.releaseDate?.prefix(4) ?? "????"
        return (
            title: "\(film.title), \(release)",
            imageURL: getImageURL(for: film),
            genreList: getGenreList(for: film),
            rating: film.voteAverage
        )
    }
    
    private func getImageURL(for film: Film) -> URL? {
        ApiManager.getBackdropImageURL(for: film.backdropPath, size: .w300)
    }
    
    private func getGenreList(for film: Film) -> [String] {
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
                genresCancellable = ApiManager.fetchGenres()
                    .sink { [weak self] response in
                        switch response.result {
                        case .failure(let error):
                            self?.errorSubject.send(error)
                        case .success(let result):
                            UserDefaults.standard.storedGenresResult = result
                            self?.tableReloadSubject.send()
                        }
                    }
            }
            
            // Provide something while loading
            return ["..."]
        }
    }
    
    func applySort(named sortName: String) {
        guard let index = sortOptions.firstIndex(where: { $0.name == sortName }) else { return }
        guard currentOptionIndex != index else { return }
        currentOptionIndex = index
        stopBizarrePagination = false
        
        print("Sort changed to '\(sortName)' ")
        // Reload films on new soerting
        reloadFilms()
    }
    
    func applySearch(_ search: String?) {
        guard nameFilter != search else { return }
        stopBizarrePagination = false
        nameFilter = search
        
        print("Search changed to '\(search ?? "nil")'")
        // Filter locally in new search
        tableReloadSubject.send()
    }
}
