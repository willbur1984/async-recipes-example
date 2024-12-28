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
    enum Section: Hashable {
        case recipes
    }
    
    enum Item: Hashable {
        case recipe(_ model: Recipe)
    }
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Public Properties
    @Published
    var searchText: String?
    @Published
    private(set) var snapshot = Snapshot()
    
    // MARK: - Private Properties
    @Published
    private var response: RecipesResponse?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Functions
    func requestContent() async -> Result<RecipesResponse, Error> {
        do {
            let (data, response) = try await URLSession.shared.data(from: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!)
            let retval = try JSONDecoder().decode(RecipesResponse.self, from: data)
            
            self.response = retval
            
            return .success(retval)
        }
        catch {
            self.response = nil
            
            return .failure(error)
        }
    }
    
    // MARK: - Initializers
    init() {
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
