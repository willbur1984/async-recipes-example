//
//  ViewController.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import Combine
import os.log
import UIKit

class ViewController: UITableViewController, UISearchResultsUpdating {
    // MARK: - Private Types
    private typealias DiffableDataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    // MARK: - Private Properties
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
        
        self.viewModel.$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.diffableDataSource.apply($0)
            }
            .store(in: &self.cancellables)
        
        Task { @MainActor in
            switch await self.viewModel.requestContent() {
            case .success(let success):
                os_log("success %@", String(describing: success))
            case .failure(let failure):
                os_log("success %@", String(describing: failure))
            }
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        self.viewModel.searchText = searchController.searchBar.text
    }
    
    private func setup() {
        self.title = String(localized: "recipes.title", defaultValue: "Recipes")
        self.navigationItem.preferredSearchBarPlacement = .inline
        self.navigationItem.searchController = UISearchController(searchResultsController: nil).also {
            $0.searchResultsUpdater = self
        }
    }
    
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

