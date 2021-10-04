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
        
        return view
    }()
    
    private lazy var searchResultsViewController: SearchResultsViewController = {
        let contoller = SearchResultsViewController()
        contoller.delegate = self
        return contoller
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: searchResultsViewController)
        controller.searchResultsUpdater = searchResultsViewController
        controller.obscuresBackgroundDuringPresentation = true
        controller.searchBar.placeholder = L10n.City.find
        controller.searchBar.barStyle = .default
        controller.hidesNavigationBarDuringPresentation = false
        
        if let textField = controller.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .white
            textField.tintColor = .white
            textField.isOpaque = true
            guard textField.subviews.count > 0 else {
                print("Warning: textField seach bar view has no subviews. It's very strange!")
                return controller
            }
            textField.subviews[0].backgroundColor = .white
            textField.subviews[0].tintColor = .white
        }
        guard controller.searchBar.subviews.count > 0 else {
            print("Warning: seach bar view has no subviews. It's very strange!")
            return controller
        }
        controller.searchBar.subviews[0].backgroundColor = Asset.accent2.color
        controller.searchBar.subviews[0].tintColor = .white
        return controller
    }()
    
    private lazy var doneButton: DoneButton = {
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
        prepareDismiss()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: Helper methods
        
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
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.showsSearchResultsButton = true
        searchController.searchBar.isOpaque = true
        searchController.searchBar.barTintColor = .black
        searchController.searchBar.tintColor = .black
        
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
                        
            doneButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 24),
            doneButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -24),
            doneButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -24),
            doneButton.heightAnchor.constraint(equalToConstant: 44),

            addCityButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16),
            addCityButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -60),
            addCityButton.heightAnchor.constraint(equalToConstant: 60),
            addCityButton.widthAnchor.constraint(equalToConstant: 60),
            
            spinner.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            spinner.widthAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.widthAnchor),
            spinner.heightAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func prepareDismiss() {
        navigationItem.searchController?.searchBar.isHidden = true
        navigationItem.searchController = nil
        viewModel.delegate = nil
        viewModel.save()        
        view.resignFirstResponder()
    }
}

extension ChoosingCitiesViewController: UITableViewDelegate, UITableViewDataSource {    
    
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
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
    }
}

extension ChoosingCitiesViewController: NSFetchedResultsControllerDelegate, Updatable {
    
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
    
    func updateUserInterface() {
        tableView.reloadData()
    }
}

extension ChoosingCitiesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        searchController.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !(searchBar.text?.isEmpty ?? true) {
            searchController.searchBar.setShowsCancelButton(false, animated: true)
        }
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
}

extension SearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let filter = searchController.searchBar.text ?? ""
        viewModel.update(with: filter)
    }
}

extension ChoosingCitiesViewController {
    @objc
    private func dismissTapped() {
        dismiss(animated: true)
    }
    
    @objc func addCityHandle() {
        let storyboard = UIStoryboard(name: "CityDetailViewController", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            vc.modalPresentationStyle = .pageSheet
            present(vc, animated: true, completion: nil)
        }
    }
}

extension ChoosingCitiesViewController: Dismissable {
    func dismiss(animated: Bool) {
        prepareDismiss()
        navigationController?.popViewController(animated: animated)
    }
}
