//
//  RecipeCell.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation
import UIKit

/**
 Displays info for a single `Recipe` in a `UITableView`
 */
final class RecipeCell: UITableViewCell {
    // MARK: - Private Properties
    private let stackView = UIStackView().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 16.0
    }
    private let verticalStackView = UIStackView().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 8.0
    }
    private let photoImageView = UIImageView().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8.0
        $0.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: 64.0),
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
        ])
    }
    private let activityIndicator = UIActivityIndicatorView(style: .medium).also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
    }
    private let nameLabel = UILabel().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsFontForContentSizeCategory = true
    }
    private let cuisineLabel = UILabel().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private var task: Task<Void, Error>? {
        willSet {
            self.task?.cancel()
        }
    }
    
    // MARK: - Public Functions
    /**
     Sets the represented `Recipe` to `model`.
     
     - Parameter model: The represented model
     */
    func setModel(_ model: Recipe) {
        self.nameLabel.text = model.name
        self.cuisineLabel.text = model.cuisine
        
        if let url = model.urlPhotoSmall {
            self.task = Task { @MainActor in
                self.activityIndicator.startAnimating()
                self.photoImageView.image = await ImageManager.shared.image(forURL: url)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - Private Functions
    private func setup() {
        self.contentView.addSubview(self.stackView.also {
            $0.addArrangedSubviews([self.photoImageView.also {
                $0.addSubview(self.activityIndicator)
                
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", metrics: nil, views: ["view": self.activityIndicator]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", metrics: nil, views: ["view": self.activityIndicator]))
            }, self.verticalStackView.also {
                $0.addArrangedSubviews([self.nameLabel, self.cuisineLabel])
            }])
        })
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view]-|", metrics: nil, views: ["view": self.stackView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view]-|", metrics: nil, views: ["view": self.stackView]))
    }
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setup()
    }
}
