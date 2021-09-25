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
    
    private var viewModel = CitiesViewModel()
            
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
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
        view.register(SubtitleTableViewCell.self,
                      forCellReuseIdentifier: "cell")
                      
        view.tableHeaderView = UIView()
        view.tableFooterView = UIView()
        
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
//        view.automaticallyShowsScopeBar = true
//        view.automaticallyShowsCancelButton = true
//        view.automaticallyShowsSearchResultsController = true
        return view
    }()
    
    private lazy var dismissButton: UIButton = {
        let height: CGFloat = 20
        let view = UIButton()
        view.setTitle("Готово", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentHorizontalAlignment = .center
        view.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        view.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
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
        configureViewModel()
        configureUI()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
        super.viewWillAppear(animated)
    }
    
    // MARK: Helper functions
    private func configureUI() {
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(dismissButton)
        configureConstraints()
    }
    
    private func configureViewModel() {
        viewModel.delegate = self
        viewModel.updateAction = { [weak self] in
            DispatchQueue.main.async {
                self?.spinner.startAnimating()
                self?.tableView.reloadData()
                self?.spinner.stopAnimating()
            }
        }
        viewModel.update()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dismissAction?()
        super.viewDidDisappear(animated)
    }
        
    private func configureNavigationBar() {
        title = L10n.Screens.choosingCitiesTitle
        guard let navigationController = navigationController else {
            return
        }
        navigationController.setToolbarHidden(true, animated: false)
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.hidesBarsWhenKeyboardAppears = false
        navigationController.hidesBarsOnTap = false
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func configureSearchController() {
//        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    private func configureConstraints() {
        let constraints: [NSLayoutConstraint] = [
            tableView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor),
            
            dismissButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -24),
//            dismissButton.widthAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.widthAnchor),
//            dismissButton.heightAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.heightAnchor),
//            dismissButton.widthAnchor.constraint(equalToConstant: 32),
//            dismissButton.heightAnchor.constraint(equalToConstant: 32),
            
            spinner.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            spinner.widthAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.widthAnchor),
            spinner.heightAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func update() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }
    
    @objc
    private func dismissTapped() {
        viewModel.save()
        AppController.shared.isFirstLaunch = false
        navigationController?.popViewController(animated: true)
    }    
}

extension ChoosingCitiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.prepareForReuse()
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "Id: \(item.id)"
        cell.accessoryType = item.isSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = viewModel.item(at: indexPath)
        if item.isSelected {
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ChoosingCitiesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if view.window == nil { return }
        spinner.startAnimating()
        tableView.beginUpdates()
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if view.window == nil { return }
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let item = viewModel.item(at: indexPath)
                if let cell = tableView.cellForRow(at: indexPath) {
                    let name = item.name
                    cell.textLabel?.text = name
                }
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if view.window == nil { return }
        tableView.endUpdates()
        spinner.stopAnimating()
    }
    
}

extension ChoosingCitiesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
