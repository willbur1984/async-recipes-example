//
//  RecipesResponse.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation

struct RecipesResponse: Decodable {
    // MARK: - Public Properties
    let recipes: [Recipe]
}
