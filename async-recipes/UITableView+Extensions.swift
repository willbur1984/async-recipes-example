//
//  UITableView+Extensions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation
import UIKit

extension UITableView {
    // MARK: - Public Functions
    func registerCellClass<T: UITableViewCell>(_ class: T.Type) {
        self.register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCellClass<T: UITableViewCell>(_ class: T.Type, for indexPath: IndexPath) -> T {
        guard let retval = self.dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell with identifier \(T.defaultReuseIdentifier)")
        }
        return retval
    }
}
