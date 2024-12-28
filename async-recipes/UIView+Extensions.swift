//
//  UIView+Extensions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation
import UIKit

extension UIView {
    // MARK: - Public Properties
    static var defaultReuseIdentifier: String {
        String(describing: self)
    }
}
