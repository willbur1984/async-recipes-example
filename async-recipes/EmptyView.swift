//
//  EmptyView.swift
//  async-recipes
//
//  Created by William Towe on 12/28/24.
//

import Foundation
import UIKit

final class EmptyView: UIView {
    // MARK: - Private Properties
    private let stackView = UIStackView().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 16.0
    }
    private let imageView = UIImageView().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsImageSizeForAccessibilityContentSizeCategory = true
        
        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: 128.0),
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
        ])
    }
    private let headlineLabel = UILabel().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .headline)
    }
    private let bodyLabel = UILabel().also {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body)
    }
    
    // MARK: - Public Functions
    func setImage(
        _ image: UIImage?,
        headline: String?,
        body: String?
    ) {
        self.imageView.image = image
        self.headlineLabel.text = headline
        self.bodyLabel.text = body
    }
    
    // MARK: - Private Functions
    private func setup() {
        self.addSubview(self.stackView.also {
            $0.addArrangedSubviews([self.imageView, self.headlineLabel, self.bodyLabel])
        })
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view]-|", metrics: nil, views: ["view": self.stackView]))
        NSLayoutConstraint.activate([
            self.stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setup()
    }
}
