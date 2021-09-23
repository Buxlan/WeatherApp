//
//  SearchResultsViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import UIKit

class SearchResultsViewController: UITableViewController {
    
    // MARK: - Properties
    var viewModel = CitiesViewModel()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = .black
        return view
    }()
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        viewModel.updateAction = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.spinner.startAnimating()
                self?.tableView.reloadData()
                self?.spinner.stopAnimating()
            }
        }
        viewModel.update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Helper functions
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.prepareForReuse()
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "Id: \(item.id)"
        cell.accessoryType = item.selected ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = viewModel.item(at: indexPath)
        if item.selected {
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

extension SearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let condition = Condition.string(searchController.searchBar.text ?? "")
        viewModel.update(with: condition)
    }
}
