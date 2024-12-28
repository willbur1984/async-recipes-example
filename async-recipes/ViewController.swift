//
//  ViewController.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

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
                self.present(UIAlertController(title: "URLs", message: "Choose a URL to open", preferredStyle: .actionSheet).also {
                    for linkURL in model.linkURLs {
                        $0.addAction(.init(title: linkURL.title, style: .default, handler: { _ in
                            self.present(SFSafariViewController(url: linkURL.url), animated: true)
                        }))
                    }
                    $0.addAction(.init(title: "Cancel", style: .cancel))
                }, animated: true)
            }
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        self.viewModel.searchText = searchController.searchBar.text
        self.viewModel.selectedScopeButtonTitle = self.viewModel.scopeButtonTitles[searchController.searchBar.selectedScopeButtonIndex]
    }
    
    private func setup() {
        self.title = String(localized: "recipes.title", defaultValue: "Recipes")
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = UISearchController(searchResultsController: nil).also {
            $0.searchResultsUpdater = self
            $0.searchBar.placeholder = "Search recipes"
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
                self.emptyView.setImage(UIImage(systemName: "fork.knife"), headline: "No Recipes", body: "Pull to refresh to fetch recipes")
            }
            catch {
                self.emptyView.setImage(UIImage(systemName: "exclamationmark.circle.fill"), headline: "Error", body: error.localizedDescription)
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

