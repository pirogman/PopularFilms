//
//  FilmsTableVC.swift
//  PopularFilms
//
//  Created by Alex Pirog on 15.01.2023.
//

import UIKit
import Combine

class FilmsTableVC: UIViewController {
    private var cancellableSet = Set<AnyCancellable>()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let hintLabel = UILabel()
    
    let vm: FilmsTableVMProtocol
    
    init(_ vm: FilmsTableVMProtocol) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellableSet.removeAll()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupSubviews()
        addConstraints()
        setupNavigationBar()
        addListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vm.reloadFilms()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        searchBar.placeholder = "Search Title"
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = FilmTableCell.estimatedHeight(in: view.frame)
        tableView.separatorStyle = .none
        tableView.register(FilmTableCell.self, forCellReuseIdentifier: FilmTableCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        hintLabel.text = "No Results"
        hintLabel.textColor = .systemGray
        hintLabel.font = .preferredFont(forTextStyle: .headline)
        hintLabel.textAlignment = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintLabel)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 32),
            hintLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 32),
            hintLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -32),
        ])
    }
    
    private func setupNavigationBar() {
        title = "Popular Films"
        
        let sortImage = UIImage(systemName: "slider.horizontal.3")
        let sortButton = UIBarButtonItem(image: sortImage, style: .plain, target: self, action: #selector(onSort))
        navigationItem.rightBarButtonItem = sortButton
        
        let loadingSpinner = UIActivityIndicatorView(style: .medium)
        loadingSpinner.startAnimating()
        let spinnerButton = UIBarButtonItem(customView: loadingSpinner)
        navigationItem.leftBarButtonItem = spinnerButton
        
        // Hide back button text on pushed VCs
        navigationItem.backButtonTitle = ""
    }
    
    private func addListeners() {
        vm.tableReloadSubject
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.tableView.reloadData()
                self.hintLabel.isHidden = self.vm.tableViewCount != 0
            }
            .store(in: &cancellableSet)
        
        vm.errorSubject
            .sink { [weak self] error in
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellableSet)
        
        vm.loadingSubject
            .sink { [weak self] isLoading in
                self?.navigationItem.leftBarButtonItem?.customView?.isHidden = !isLoading
            }
            .store(in: &cancellableSet)
    }
    
    // MARK: - Sorting
    
    @objc private func onSort() {
        let sortSheet = UIAlertController(title: "Sort", message: nil, preferredStyle: .actionSheet)
        for option in vm.sortOptions {
            let action = UIAlertAction(title: option.name, style: .default, handler: onSortAction)
            sortSheet.addAction(action)
        }
        sortSheet.addAction(UIAlertAction.init(title: "Cancel", style: .cancel))
        present(sortSheet, animated: true)
    }
    
    private func onSortAction(_ action: UIAlertAction) {
        vm.applySort(named: action.title!)
    }
}

// MARK: - Delegates

extension FilmsTableVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.applySearch(searchText)
        
        // Scroll back to top on search changes
        if vm.tableViewCount > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension FilmsTableVC: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.tableViewCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilmTableCell.reuseId, for: indexPath) as! FilmTableCell
        
        if let info = vm.getFilmInfo(at: indexPath) {
            cell.setTo(info: info)
        } else {
            cell.setToEmpty()
            vm.paginateWhenSearch()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Shadow for the cell
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard ApiManager.isReachable else {
            let alert = UIAlertController(title: "Error", message: "You are offline. Please, enable your Wi-Fi or connect using cellular data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        if let film = vm.getFilm(at: indexPath) {
            let detailsVM = FilmDetailsVM(film)
            let detailsVC = FilmDetailsVC(detailsVM)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        vm.paginate(at: indexPaths)
    }
}
