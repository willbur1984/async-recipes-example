//
//  Recipe.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Foundation

/**
 Represents a single recipe.
 */
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
    
    struct LinkURL {
        // MARK: - Public Properties
        let title: String
        let url: URL
    }
    
    // MARK: - Public Properties
    let id: String
    let name: String
    let cuisine: String
    let urlPhotoSmall: URL?
    let urlPhotoLarge: URL?
    let urlSource: URL?
    let urlYouTube: URL?
    
    /**
     Returns a list of `LinkURL` instances that can be navigated to using `SFSafariViewController`.
     */
    var linkURLs: [LinkURL] {
        [LinkURL]().also {
            if let url = self.urlSource {
                $0.append(.init(title: String(localized: "link-urls.source.title", defaultValue: "Source URL"), url: url))
            }
            if let url = self.urlYouTube {
                $0.append(.init(title: String(localized: "link-urls.youtube.title", defaultValue: "YouTube URL"), url: url))
            }
        }
    }
    
    // MARK: - Comparable
    static func < (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.name < rhs.name
    }
}
