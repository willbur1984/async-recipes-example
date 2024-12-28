//
//  URL+Extensions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation

extension URL {
    // MARK: - Public Properties
    static let recipesAll = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
    static let recipesEmpty = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
    static let recipesError = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!
    
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
