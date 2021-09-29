//
//  ViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

import UIKit
import Foundation
import CoreData

protocol Observer: class {
    func notify()    
}

protocol Updateable: class {
    func update()
}

protocol Navigatable: class {
    func prepareNavigation(viewController: UIViewController)
}

class MainViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel = MainViewModel()
            
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.accessibilityIdentifier = "Main"
        view.isUserInteractionEnabled = true
        view.backgroundColor = .white
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
                      
//        view.tableHeaderView = UIView()
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
    
    private lazy var addCitiesButton: UIButton = {
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
        view.clipsToBounds = true
        view.backgroundColor = Asset.accent2.color
        return view
    }()
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
//        viewModel.updateAction = { [weak self] in
//            DispatchQueue.main.async {
//                self?.spinner.startAnimating()
//                self?.tableView.reloadData()
//                self?.spinner.stopAnimating()
//            }
//        }
        viewModel.update()        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appController = AppController()
        if appController.isFirstLaunch {
            segueToChoosingCities()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        viewModel.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.delegate = nil
        super.viewWillDisappear(animated)                
    }
    
    // MARK: Helper functions
    func configureUI() {
        view.backgroundColor = Asset.accent2.color
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(addCitiesButton)
        configureConstraints()
    }
    
    private func configureNavigationBar() {
        title = L10n.Screens.mainTitle
//        guard let navigationController = navigationController else {
//            return
//        }
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureConstraints() {
        let constraints: [NSLayoutConstraint] = [
            tableView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            
            addCitiesButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            addCitiesButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -24),
            addCitiesButton.heightAnchor.constraint(equalToConstant: 44),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc
    private func addCitiesTapped() {
        segueToChoosingCities()
    }
    
    private func segueToChoosingCities() {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DailyWeatherViewController()
        viewModel.prepareNavigation(to: vc, indexPath)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.cellModel(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch cell {
        case let cell as Configurable:
            cell.configure(data: model)
        default:
            print("Warning: Strange cell type?!")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.itemsCount
    }
}

extension MainViewController: Navigatable, Updateable {

    func prepareNavigation(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func update() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }
    
}

extension MainViewController: NSFetchedResultsControllerDelegate {
        
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}
