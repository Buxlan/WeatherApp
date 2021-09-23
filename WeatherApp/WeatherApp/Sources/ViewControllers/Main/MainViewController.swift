//
//  ViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

import UIKit
import Foundation
import CoreData

protocol Observer {
    func notify()
}

class MainViewController: UIViewController {
    
    // MARK: - Properties
    typealias Item = ChoosedCity
    private var viewModel = MainViewModel()
            
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.isUserInteractionEnabled = true
        view.delegate = self
        view.dataSource = self
        view.allowsSelection = true
        view.allowsMultipleSelection = false
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
    
    private lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = .black
        return view
    }()
    
    private lazy var addCities: UIButton = {
        let height: CGFloat = 20
        let view = UIButton()
        view.setTitle(L10n.Buttons.addCities, for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentHorizontalAlignment = .center
        view.addTarget(self, action: #selector(addCitiesTapped), for: .touchUpInside)
        view.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.update()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let appController = AppController()
        if appController.isFirstLaunch {
            sequeToChoosingCities()
            viewModel.update()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
    }
    
    // MARK: Helper functions
    func configureUI() {
        spinner.startAnimating()
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(addCities)
        configureConstraints()
    }
    
    private func configureNavigationBar() {
        title = L10n.Screens.mainTitle
        guard let navigationController = navigationController else {
            return
        }
        navigationController.setToolbarHidden(true, animated: false)
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    private func configureConstraints() {
        let constraints: [NSLayoutConstraint] = [
            tableView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            
            addCities.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            addCities.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -24)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc
    private func addCitiesTapped() {
        sequeToChoosingCities()
    }
    
    private func sequeToChoosingCities() {
        let vc = ChoosingCitiesViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.dismissAction = { [weak self] in
            guard let self = self else {
                return
            }
            self.spinner.startAnimating()
            self.viewModel.update()
            self.spinner.stopAnimating()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.prepareForReuse()
        cell.textLabel?.text = item.city.name
        cell.detailTextLabel?.text = "Id: \(item.city.id)"
        return cell
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension MainViewController {
    private func prepareToFirstLaunch() {
        // Load cities
        var isOk = true
        if !AppController.shared.areCitiesLoaded {
            isOk = CityManager.initCitiesFromFile()
            if isOk {
                AppController.shared.areCitiesLoaded = true
            }
        }
    }
}

extension MainViewController: Observer {
    func notify() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.spinner.stopAnimating()
        }
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let item = viewModel.item(at: indexPath)
                let cell = tableView.cellForRow(at: indexPath)!
                let name = item.city.name
                cell.textLabel?.text = name
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
        tableView.endUpdates()
    }
    
}
