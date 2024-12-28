//
//  ViewModel.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Combine
import Foundation
import UIKit

extension NSDiffableDataSourceSnapshot: ScopeFunctions {}

final class ViewModel {
    // MARK: - Public Types
    struct ScopeButtonTitle: Hashable {
        // MARK: - Public Properties
        let title: String
        let url: URL
    }
    
    enum Section: Hashable {
        case recipes
    }
    
    enum Item: Hashable, ScopeFunctions {
        case recipe(_ model: Recipe)
    }
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Public Properties
    let scopeButtonTitles: [ScopeButtonTitle] = [
        .init(title: "All", url: .recipesAll),
        .init(title: "Error", url: .recipesError),
        .init(title: "Empty", url: .recipesEmpty)
    ]
    
    @Published
    var searchText: String?
    var selectedScopeButtonTitle: ScopeButtonTitle
    @Published
    private(set) var snapshot = Snapshot()
    
    // MARK: - Private Properties
    @Published
    private var response: RecipesResponse?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Functions
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
                            recipe.name.localizedCaseInsensitiveContains($0)
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
