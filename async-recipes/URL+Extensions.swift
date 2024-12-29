//
//  URL+Extensions.swift
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

extension URL {
    // MARK: - Public Properties
    static let recipesAll = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
    static let recipesEmpty = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
    static let recipesError = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!
    
    /**
     Returns whether the file url is reachable.
     */
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
