//
//  UIView+Extensions.swift
//  PopularFilms
//
//  Created by Alex Pirog on 22.01.2023.
//

import UIKit

extension UIView {
    /// Activates top, leading, trailing and bottom constraints to match a given view with constraint value
    func activateEdgeConstraints(to otherView: UIView, constant: CGFloat = 0) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: otherView.topAnchor, constant: constant),
            self.leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: constant),
            self.trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: -constant),
            self.bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: -constant),
        ])
    }
}
