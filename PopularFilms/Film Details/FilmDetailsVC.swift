//
//  FilmDetailsVC.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import UIKit
import Combine

class FilmDetailsVC: UIViewController {
    private var cancellableSet = Set<AnyCancellable>()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let releaseLabel = UILabel()
    private let genresLabel = UILabel()
    private let videoButton = UIButton()
    private let noVideoLabel = UILabel()
    private let ratingLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    let vm: FilmDetailsVMProtocol
    
    init(_ vm: FilmDetailsVMProtocol) {
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.delegate = self
        scrollView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        vm.loadVideoLink()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        scrollView.isDirectionalLockEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        posterImageView.backgroundColor = .gray.withAlphaComponent(0.3)
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterImageView)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        releaseLabel.font = .preferredFont(forTextStyle: .subheadline)
        releaseLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(releaseLabel)
        
        genresLabel.textColor = .systemGray
        genresLabel.font = .preferredFont(forTextStyle: .body)
        genresLabel.textAlignment = .left
        genresLabel.numberOfLines = 0
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genresLabel)
        
        videoButton.addTarget(self, action: #selector(onVideo), for: .touchUpInside)
        videoButton.setImage(UIImage(systemName: "play.rectangle.fill"), for: .normal)
        videoButton.tintColor = .white
        videoButton.backgroundColor = .black
        videoButton.layer.cornerRadius = Constants.buttonSize / 2
        videoButton.clipsToBounds = true
        videoButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(videoButton)
        
        noVideoLabel.text = "No Trailer"
        noVideoLabel.textColor = .systemGray
        noVideoLabel.font = .preferredFont(forTextStyle: .headline)
        noVideoLabel.textAlignment = .right
        noVideoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noVideoLabel)
        
        ratingLabel.textColor = .systemGray
        ratingLabel.font = .preferredFont(forTextStyle: .headline)
        ratingLabel.textAlignment = .right
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingLabel)
        
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.posterPadding),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: Constants.posterRatio),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: Constants.vSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.hSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.hSpacing),
            
            releaseLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.vSpacing),
            releaseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.hSpacing),
            releaseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.hSpacing),
            
            genresLabel.topAnchor.constraint(equalTo: releaseLabel.bottomAnchor, constant: Constants.vSpacing),
            genresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.hSpacing),
            genresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.hSpacing),
            
            videoButton.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: Constants.vSpacing),
            videoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.hSpacing),
            videoButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            videoButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            noVideoLabel.centerYAnchor.constraint(equalTo: videoButton.centerYAnchor),
            noVideoLabel.leadingAnchor.constraint(equalTo: videoButton.leadingAnchor),
            
            ratingLabel.centerYAnchor.constraint(equalTo: videoButton.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: videoButton.trailingAnchor, constant: Constants.hSpacing),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.hSpacing),
            
            descriptionLabel.topAnchor.constraint(equalTo: videoButton.bottomAnchor, constant: Constants.vSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.hSpacing),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.hSpacing),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.vSpacing),
        ])
    }
    
    private func setupNavigationBar() {
        title = vm.title
        
        let loadingSpinner = UIActivityIndicatorView(style: .medium)
        loadingSpinner.startAnimating()
        let spinnerButton = UIBarButtonItem(customView: loadingSpinner)
        navigationItem.rightBarButtonItem = spinnerButton
    }
    
    private func addListeners() {
        vm.updateSubject
            .sink { [weak self] in
                self?.updateUI()
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
                self?.navigationItem.rightBarButtonItem?.customView?.isHidden = !isLoading
            }
            .store(in: &cancellableSet)
    }
    
    // MARK: -
    
    @objc private func onTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        if posterImageView.frame.contains(gesture.location(in: scrollView)) {
            if vm.canViewPoster {
                let vc = ImageScrollVC()
                vc.url = vm.fullImageURL ?? vm.posterURL
                vc.name = "Poster"
                let navVC = UINavigationController(rootViewController: vc)
                present(navVC, animated: true)
            }
        }
    }
    
    @objc private func onVideo(_ button: UIButton) {
        guard case let .available(videoURL) = vm.video else { return }
        let vc = YTVideoVC()
        vc.url = videoURL
        vc.name = "Trailer"
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func updateUI() {
        posterImageView.kf.setImage(with: vm.posterURL, placeholder: UIImage(named: "vPlaceholder"))
        titleLabel.text = vm.title
        releaseLabel.text = vm.releaseDate
        genresLabel.text = "Genres: " + vm.genres.joined(separator: ", ")
        videoButton.isHidden = true
        noVideoLabel.isHidden = true
        switch vm.video {
        case .available: videoButton.isHidden = false
        case .unavailable: noVideoLabel.isHidden = false
        case .loading: break
        }
        ratingLabel.text = "Rating: " + String(format: "%.1f", vm.rating)
        descriptionLabel.text = vm.description
    }
}

// MARK: - Delegate

extension FilmDetailsVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Constants

extension FilmDetailsVC {
    private enum Constants {
        static let posterPadding: CGFloat = 8
        static let posterRatio: CGFloat = 1.5 // Width to height, like 500x750
        static let buttonSize: CGFloat = 36
        static let vSpacing: CGFloat = 8
        static let hSpacing: CGFloat = 16
    }
}
