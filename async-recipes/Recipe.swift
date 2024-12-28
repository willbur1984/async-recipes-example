//
//  Recipe.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation

struct Recipe: Comparable, Decodable, Hashable, Identifiable {
    // MARK: - Public Types
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case cuisine
        case urlPhotoSmall = "photo_url_small"
        case urlPhotoLarge = "photo_url_large"
        case urlSource = "source_url"
        case urlYouTube = "youtube_url"
    }
    
    // MARK: - Public Properties
    let id: String
    let name: String
    let cuisine: String
    let urlPhotoSmall: URL?
    let urlPhotoLarge: URL?
    let urlSource: URL?
    let urlYouTube: URL?
    
    // MARK: - Comparable
    static func < (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.name < rhs.name
    }
}
