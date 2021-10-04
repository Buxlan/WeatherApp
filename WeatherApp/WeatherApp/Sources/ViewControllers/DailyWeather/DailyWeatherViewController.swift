//
//  WeatherByDateViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/25/21.
//

import UIKit
import CoreData

class DailyWeatherViewController: UIViewController {
    
    // MARK: - Properties
    typealias Item = City
    
    var city: Item? {
        didSet {
            viewModel.city = city
            if let city = city {
                let text = city.name
                let detailText = "\(city.currentWeather?.temp ?? 0.0)"
                let model = MainDataModel(text: text, detailText: detailText)
                self.cityView.configure(data: model)
            }
        }
    }
    
    private var viewModel = DailyWeatherViewModel()
    
    private lazy var cityView: CityView = {
        CityView(frame: CGRect(x: 0, y: 0, width: 0, height: 140))
    }()
            
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
        view.register(MainViewTableCell.self,
                      forCellReuseIdentifier: "cell")
                      
        view.tableHeaderView = cityView
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
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        viewModel.delegate = self
        viewModel.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.delegate = nil
    }
    
    // MARK: Helper methods
    func configureUI() {
        spinner.startAnimating()
        view.addSubview(tableView)
        view.addSubview(spinner)
        configureConstraints()
        configureGestures()
    }
    
    private func configureNavigationBar() {
        title = L10n.Screens.dailyScreenTitle
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
            spinner.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension DailyWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.itemData(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch cell {
        case let cell as Configurable:
            cell.configure(data: item)
        default:
            print("Warning: Strange cell (is not Configurable)")
        }
        return cell
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension DailyWeatherViewController: Updatable {
    func updateUserInterface() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.tableView.reloadData()
        }
    }
}

extension DailyWeatherViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            print("Move or update: need to do something with that")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath,
               let cell = tableView.cellForRow(at: indexPath) as? Configurable {
                let data = viewModel.itemData(at: indexPath)
                cell.configure(data: data)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            fatalError()
        }
    }
        
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension DailyWeatherViewController: ViewModelStateDelegate {
    func didChangeTableViewState(new state: UserInterfaceStatus) {
        DispatchQueue.main.async {
            switch state {
            case .loading:
                self.spinner.startAnimating()
            case .normal:
                self.spinner.stopAnimating()
            }
        }
    }
}

extension DailyWeatherViewController {
    private func configureGestures() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
    }
    
    @objc
    private func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
