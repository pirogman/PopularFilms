//
//  YTVideoVC.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import UIKit
import WebKit

class YTVideoVC: UIViewController {
    let webView = WKWebView()
    
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
        
        if let videoURL = url {
            webView.load(URLRequest(url: videoURL))
        }
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
    }
    
    private func addConstraints() {
        webView.activateEdgeConstraints(to: view)
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
}
