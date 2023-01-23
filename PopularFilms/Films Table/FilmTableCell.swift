//
//  FilmTableCell.swift
//  PopularFilms
//
//  Created by Alex Pirog on 19.01.2023.
//

import UIKit

class FilmTableCell: UITableViewCell {
    static let reuseId = "FilmTableCell"
    static func estimatedHeight(in rect: CGRect) -> CGFloat {
        // Padding, title height, spacing, image height, spacing, genres height, padding
        Constants.cellVPadding + UIFont.preferredFont(forTextStyle: .headline).lineHeight
        + Constants.vSpacing + (rect.width - Constants.cellHPadding * 2) * Constants.backdropRatio
        + Constants.vSpacing + UIFont.preferredFont(forTextStyle: .body).lineHeight
        + Constants.cellVPadding
    }
    
    let titleLabel = UILabel()
    let posterImageView = UIImageView()
    let genresLabel = UILabel()
    let ratingLabel = UILabel()
    let loader = UIActivityIndicatorView(style: .large)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        posterImageView.backgroundColor = .gray.withAlphaComponent(0.3)
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.cornerRadius = Constants.imageCorner
        posterImageView.clipsToBounds = true
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterImageView)
        
        genresLabel.textColor = .systemGray
        genresLabel.font = .preferredFont(forTextStyle: .body)
        genresLabel.textAlignment = .left
        genresLabel.numberOfLines = 0
        genresLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genresLabel)
        
        ratingLabel.textColor = .systemGray
        ratingLabel.font = .preferredFont(forTextStyle: .body)
        ratingLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingLabel)
        
        loader.color = .white
        loader.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loader)
        
        // Shadow behind the cell
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.label.cgColor
        contentView.backgroundColor = .systemBackground
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.cellVPadding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cellHPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellHPadding),
            
            posterImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.vSpacing),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cellHPadding),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellHPadding),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: Constants.backdropRatio),
            
            genresLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: Constants.vSpacing),
            genresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cellHPadding),
            genresLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingLabel.leadingAnchor, constant: -Constants.hSpacing),
            genresLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.cellVPadding),
            
            ratingLabel.topAnchor.constraint(equalTo: genresLabel.topAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellHPadding),
            
            loader.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
        ])
    }
}

// MARK: - Constants

extension FilmTableCell {
    private enum Constants {
        static let cellVPadding: CGFloat = 8
        static let cellHPadding: CGFloat = 16
        static let vSpacing: CGFloat = 4
        static let hSpacing: CGFloat = 12
        static let backdropRatio: CGFloat = 0.563 // Width to height
        static let imageCorner: CGFloat = 4
    }
}

// MARK: - Update UI

typealias FilmInfo = (title: String, imageURL: URL?, genreList: [String], rating: Double)

extension FilmTableCell {
    func setTo(info: FilmInfo) {
        titleLabel.text = info.title
        posterImageView.kf.setImage(with: info.imageURL, placeholder: UIImage(named: "hPlaceholder"))
        genresLabel.text = "Genres: " + info.genreList.joined(separator: ", ")
        ratingLabel.text = String(format: "%.1f", info.rating)
        
        loader.isHidden = true
        loader.stopAnimating()
    }
    
    func setToEmpty() {
        titleLabel.text = "..."
        posterImageView.image = nil
        genresLabel.text = "Genres: ..."
        ratingLabel.text = "..."
        
        loader.isHidden = false
        loader.startAnimating()
    }
}
