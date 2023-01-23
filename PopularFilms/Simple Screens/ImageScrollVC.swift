//
//  ImageScrollVC.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import UIKit

class ImageScrollVC: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let imageView = UIImageView()
    let loader = UIActivityIndicatorView(style: .large)
    
    var name: String?
    var url: URL?
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupSubviews()
        addConstraints()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loader.startAnimating()
        imageView.kf.setImage(with: url) { [weak self] result in
            switch result {
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let closeAndDismiss = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
                    self?.close()
                }
                alert.addAction(closeAndDismiss)
                self?.present(alert, animated: true)
            case .success(let kfResult):
                self?.updateZoom(to: kfResult.image.size)
                self?.loader.stopAnimating()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        scrollView.maximumZoomScale = 2.0
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        imageView.backgroundColor = .gray.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loader)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loader.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])
        
        contentView.activateEdgeConstraints(to: scrollView)
        imageView.activateEdgeConstraints(to: contentView)
    }
    
    private func setupNavigationBar() {
        title = name
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    // MARK: -
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    private func updateZoom(to size: CGSize) {
        let zoomScale = min(scrollView.bounds.width / size.width,
                            scrollView.bounds.height / size.height)
        scrollView.minimumZoomScale = zoomScale > 1 ? 1 : zoomScale
        scrollView.zoomScale = zoomScale
    }
}

// MARK: - Delegate

extension ImageScrollVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
