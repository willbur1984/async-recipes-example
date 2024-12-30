//
//  ViewController.swift
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
import os.log
import SafariServices
import UIKit

class ViewController: UITableViewController, UISearchResultsUpdating {
    // MARK: - Private Types
    private typealias DiffableDataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    // MARK: - Private Properties
    private let emptyView = EmptyView()
    private lazy var diffableDataSource: DiffableDataSource = { [unowned self] in
        DiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            tableView.dequeueReusableCellClass(RecipeCell.self, for: indexPath).also {
                switch itemIdentifier {
                case .recipe(let model):
                    $0.setModel(model)
                }
            }
        }
    }()
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = ViewModel()
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerCellClass(RecipeCell.self)
        self.tableView.backgroundView = self.emptyView
        self.refreshControl = UIRefreshControl().also {
            $0.addAction(.init(handler: { [weak self] _ in
                self?.refreshContent()
            }), for: .valueChanged)
        }
        
        self.viewModel.$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.diffableDataSource.apply($0)
            }
            .store(in: &self.cancellables)
        
        self.refreshContent()
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.diffableDataSource.itemIdentifier(for: indexPath)?.let {
            switch $0 {
            case .recipe(let model):
                guard model.linkURLs.isEmpty.not() else {
                    return
                }
                self.present(UIAlertController(title: String(localized: "alert.urls.title", defaultValue: "URLs"), message: String(localized: "alert.urls.message", defaultValue: "Choose a URL to open"), preferredStyle: .actionSheet).also {
                    for linkURL in model.linkURLs {
                        $0.addAction(.init(title: linkURL.title, style: .default, handler: { _ in
                            self.present(SFSafariViewController(url: linkURL.url), animated: true)
                        }))
                    }
                    $0.addAction(.init(title: String(localized: "button.cancel", defaultValue: "Cancel"), style: .cancel))
                }, animated: true)
            }
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        self.viewModel.searchText = searchController.searchBar.text
        self.viewModel.selectedScopeButtonTitle = self.viewModel.scopeButtonTitles[searchController.searchBar.selectedScopeButtonIndex]
    }
    
    // MARK: - Private Functions
    private func setup() {
        self.title = String(localized: "recipes.title", defaultValue: "Recipes")
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = UISearchController(searchResultsController: nil).also {
            $0.searchResultsUpdater = self
            $0.searchBar.placeholder = String(localized: "recipes.search.placeholder", defaultValue: "Search by name or cuisine")
            $0.searchBar.showsScopeBar = true
            $0.searchBar.scopeButtonTitles = self.viewModel.scopeButtonTitles.map {
                $0.title
            }
        }
    }
    
    private func refreshContent() {
        Task { @MainActor in
            defer {
                self.refreshControl?.endRefreshing()
            }
            do {
                let response = try await self.viewModel.requestContent()
                
                guard response.recipes.isEmpty else {
                    self.emptyView.setImage(nil, headline: nil, body: nil)
                    return
                }
                self.emptyView.setImage(UIImage(systemName: "fork.knife"), headline: String(localized: "recipes.empty.headline", defaultValue: "No Recipes"), body: String(localized: "recipes.empty.body", defaultValue: "Pull to refresh to fetch recipes"))
            }
            catch {
                self.emptyView.setImage(UIImage(systemName: "exclamationmark.circle.fill"), headline: String(localized: "recipes.empty.error.headline", defaultValue: "Error"), body: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Initializers
    override init(style: UITableView.Style) {
        super.init(style: style)
        
        self.setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setup()
    }
}

