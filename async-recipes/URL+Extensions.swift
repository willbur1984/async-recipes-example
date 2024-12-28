//
//  URL+Extensions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation

extension URL {
    // MARK: - Public Properties
    var isFileURLReachable: Bool {
        do {
            return try self.checkResourceIsReachable()
        }
        catch {
            return false
        }
    }
    
    // MARK: - Public Functions
    func toSHA1String() -> String? {
        self.absoluteString.data(using: .utf8)?.toSHA1String()
    }
}
