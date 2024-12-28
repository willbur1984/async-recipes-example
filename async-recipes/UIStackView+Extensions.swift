//
//  UIStackView+Extensions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation
import UIKit

extension UIStackView {
    // MARK: - Public Functions
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
