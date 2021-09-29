//
//  SelectingCitiesViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import UIKit
import CoreData

class ChoosingCitiesViewController: UIViewController {

    // MARK: - Properties
    var dismissAction: (() -> Void)?
    
    typealias CellType = SubtitleTableViewCell
    private var viewModel = CitiesViewModel()
            
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.accessibilityIdentifier = "ChoosingCities"
        view.isUserInteractionEnabled = true
        view.delegate = self
        view.dataSource = self
        view.allowsSelection = true
        view.allowsMultipleSelection = true
        view.allowsSelectionDuringEditing = false
        view.allowsMultipleSelectionDuringEditing = false
        view.setEditing(false, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = UITableView.automaticDimension
        view.backgroundColor = .white
        view.register(CellType.self,
                      forCellReuseIdentifier: CellType.reuseIdentifier)
                      
        view.tableHeaderView = UIView()
        view.tableFooterView = UIView()
        
        view.prefetchDataSource = self
        
        return view
    }()
    private lazy var searchResultsViewController: SearchResultsViewController = {
        SearchResultsViewController()
    }()
    private lazy var searchController: UISearchController = {
        let view = UISearchController(searchResultsController: searchResultsViewController)
        view.searchResultsUpdater = searchResultsViewController
        view.obscuresBackgroundDuringPresentation = true
        view.searchBar.placeholder = "Найти город"
        view.searchBar.barStyle = .default
        view.hidesNavigationBarDuringPresentation = false
        
        if let textField = view.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .white
            textField.tintColor = .white
        }
        return view
    }()
    
    private lazy var doneButton: UIButton = {
        let view = DoneButton()
        view.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var addCityButton: AddCityButton = {
        let view = AddCityButton()
        view.addTarget(self, action: #selector(addCityHandle), for: .touchUpInside)
        return view
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = .black
        return view
    }()
    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.delegate = self
        viewModel.update()
        configureNavigationBar()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.save()
        viewModel.delegate = nil
        view.resignFirstResponder()
    }
    
    // MARK: Helper functions
    
    override func viewDidDisappear(_ animated: Bool) {
        dismissAction?()
        super.viewDidDisappear(animated)
    }
        
    private func configureNavigationBar() {
        title = L10n.Screens.choosingCitiesTitle
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsWhenKeyboardAppears = false
        navigationController?.hidesBarsOnTap = false
        navigationItem.setHidesBackButton(false, animated: false)
    }
    
    private func configureSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.showsSearchResultsButton = true
        searchController.searchBar.barTintColor = .black
//        searchController.searchBar.searchTextField.backgroundColor = .white
        definesPresentationContext = true
    }
    
    private func configureUI() {
        view.backgroundColor = Asset.accent2.color
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(doneButton)
        view.addSubview(addCityButton)
        configureSearchController()
        configureConstraints()
    }
    
    private func configureConstraints() {
        let constraints: [NSLayoutConstraint] = [
            
            tableView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            doneButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -24),
            doneButton.heightAnchor.constraint(equalTo: addCityButton.heightAnchor),

            addCityButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16),
            addCityButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            addCityButton.heightAnchor.constraint(equalToConstant: 44),
            addCityButton.widthAnchor.constraint(equalToConstant: 44),
            
            spinner.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            spinner.widthAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.widthAnchor),
            spinner.heightAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc
    private func dismissTapped() {
        viewModel.save()
        AppController.shared.isFirstLaunch = false
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addCityHandle() {
        let storyboard = UIStoryboard(name: "CityDetailViewController", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            vc.modalTransitionStyle = .crossDissolve
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension ChoosingCitiesViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.reuseIdentifier, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = viewModel.item(at: indexPath)
        if let castedCell = cell as? Configurable {
            let model = viewModel.cellModel(at: indexPath)
            castedCell.configure(data: model)
        }
        if item.isChosen {
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.reuseIdentifier, for: indexPath)
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.reuseIdentifier, for: indexPath)
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ChoosingCitiesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
}

extension ChoosingCitiesViewController: NSFetchedResultsControllerDelegate, Updateable {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
                
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let item = viewModel.cellModel(at: indexPath)
                if let cell = tableView.cellForRow(at: indexPath) as? Configurable {
                    cell.configure(data: item)
                }
            }
        case .move:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func update() {
        tableView.reloadData()
    }
}
