//
//  Recipe.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
