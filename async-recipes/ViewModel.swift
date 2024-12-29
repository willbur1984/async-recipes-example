//
//  ViewModel.swift
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

import Combine
import Foundation
import UIKit

extension NSDiffableDataSourceSnapshot: ScopeFunctions {}

/**
 Manages the required state for `ViewController`.
 */
final class ViewModel {
    // MARK: - Public Types
    /**
     Represents a single scope button title in a `UISearchController`.
     */
    struct ScopeButtonTitle: Hashable {
        // MARK: - Public Properties
        /**
         The localized title.
         */
        let title: String
        /**
         The content url.
         */
        let url: URL
    }
    
    /**
     Represents a single section in a vended `Snapshot`.
     */
    enum Section: Hashable {
        /**
         The recipes section.
         */
        case recipes
    }
    
    /**
     Represents a single item in a vended `Snapshot`.
     */
    enum Item: Hashable, ScopeFunctions {
        /**
         A single recipe.
         */
        case recipe(_ model: Recipe)
    }
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Public Properties
    /**
     The list of scope button titles to display.
     */
    let scopeButtonTitles: [ScopeButtonTitle] = [
        .init(title: String(localized: "recipes.scope-button-titles.all", defaultValue: "All"), url: .recipesAll),
        .init(title: String(localized: "recipes.scope-button-titles.error", defaultValue: "Error"), url: .recipesError),
        .init(title: String(localized: "recipes.scope-button-titles.empty", defaultValue: "Empty"), url: .recipesEmpty)
    ]
    
    /**
     Set/get the search text used to filter the vended `snapshot`.
     */
    @Published
    var searchText: String?
    /**
     Set/get the selected scope button title.
     */
    var selectedScopeButtonTitle: ScopeButtonTitle
    /**
     Get the current snapshot.
     */
    @Published
    private(set) var snapshot = Snapshot()
    
    // MARK: - Private Properties
    @Published
    private var response: RecipesResponse?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Functions
    /**
     Asynchronously requests and returns a recipes response based on `selectedScopeButtonTitle` or throws an error.
     */
    func requestContent() async throws -> RecipesResponse {
        do {
            let (data, _) = try await URLSession.shared.data(from: self.selectedScopeButtonTitle.url)
            let retval = try JSONDecoder().decode(RecipesResponse.self, from: data)
            
            self.response = retval
            
            return retval
        }
        catch {
            self.response = nil
            throw error
        }
    }
    
    // MARK: - Initializers
    init() {
        self.selectedScopeButtonTitle = self.scopeButtonTitles.first!
        
        self.$response
            .combineLatest(self.$searchText)
            .map { response, searchText in
                Snapshot().also {
                    $0.appendSections([.recipes])
                    $0.appendItems(response?.recipes.filter { recipe in
                        searchText?.takeUnless {
                            $0.isEmpty
                        }?.let {
                            recipe.name.localizedCaseInsensitiveContains($0) || recipe.cuisine.localizedStandardContains($0)
                        } ?? true
                    }.map {
                        .recipe($0)
                    } ?? [], toSection: .recipes)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.snapshot = $0
            }
            .store(in: &self.cancellables)
    }
}
