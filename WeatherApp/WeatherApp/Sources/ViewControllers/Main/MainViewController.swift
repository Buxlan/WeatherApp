//
//  ViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

// Старался делать согласно паттерна MVVM, применяя правило, что VC должен знать о
// Инстанцируется из пустого storyboard
// Интерфейс написан программно.

import UIKit
import Foundation
import CoreData

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
        view.allowsSelectionDuringEditing = true
        view.allowsMultipleSelectionDuringEditing = false
        view.setEditing(false, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = UITableView.automaticDimension
        view.register(MainViewTableCell.self,
                      forCellReuseIdentifier: "cell")
                
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
    
    private lazy var determineLocationButton: LoadingButton = {
        let view = LoadingButton()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(determineLocationHandler), for: .touchUpInside)
        view.contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        let image = Asset.locationFill.image
        view.setImage(image, for: .normal)
        view.backgroundColor = Asset.accent2.color
        return view
    }()
    
    private lazy var addCitiesButton: ShadowButton = {
        let height: CGFloat = 20
        let text = L10n.Buttons.addCities
        let view = ShadowButton(title: text, image: nil)
        view.setTitleColor(.black, for: .normal)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentHorizontalAlignment = .center
        view.addTarget(self, action: #selector(addCitiesHandler), for: .touchUpInside)
        view.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        view.backgroundColor = Asset.accent2.color
        return view
    }()
    
    private lazy var cityView: CityView = {
        let view = CityView()
        return view
    }()
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
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
        viewModel.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.delegate = nil
        super.viewWillDisappear(animated)                
    }
    
    // MARK: Helper methods
    func configureUI() {
        view.backgroundColor = Asset.accent2.color
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(addCitiesButton)
        view.addSubview(determineLocationButton)
        configureConstraints()
    }
    
    private func configureNavigationBar() {
        title = L10n.Screens.mainTitle
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = Asset.accent2.color

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance

        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.barTintColor = Asset.accent2.color
        }
    }
    
    private func configureConstraints() {
        let constraints: [NSLayoutConstraint] = [
            tableView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            
            addCitiesButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 24),
            addCitiesButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -24),
            addCitiesButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -24),
            addCitiesButton.heightAnchor.constraint(equalToConstant: 44),
            
            determineLocationButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -24),
            determineLocationButton.bottomAnchor.constraint(equalTo: addCitiesButton.topAnchor, constant: -60),
            determineLocationButton.heightAnchor.constraint(equalToConstant: 60),
            determineLocationButton.widthAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc
    private func addCitiesHandler() {
        segueToChoosingCities()
    }
    
    @objc
    private func determineLocationHandler(_ sender: UIButton) {
        if let sender = sender as? LoadingButton {
            sender.startAnimating()
            viewModel.performDeterminingCurrentCity()
        }
    }
    
    private func segueToChoosingCities() {
        let vc = ChoosingCitiesViewController()
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.cellData(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch cell {
        case let cell as Configurable:
            cell.configure(data: model)
        default:
            print("Warning: Strange cell type?!")
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let data = viewModel.sectionData(section: section)
        return data.text
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DailyWeatherViewController()
        viewModel.prepareSegue(to: vc, indexPath)
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal,
                                                title: "Delete") { (_, indexPath) in
            self.viewModel.deleteItem(at: indexPath)
        }
        deleteAction.backgroundColor = Asset.accent2.color
        return [deleteAction]
    }
}

extension MainViewController: Navigatable,
                              Updatable,
                              ViewModelStateDelegate,
                              ViewStateDelegate {
    func didChangeViewState(new status: UserInterfaceStatus) {
        switch status {
        case .loading:
            self.determineLocationButton.startAnimating()
        default:
            self.determineLocationButton.stopAnimating()
        }
    }
    
    func didChangeTableViewState(new status: UserInterfaceStatus) {
        switch status {
        case .loading:
            self.spinner.startAnimating()
        default:
            self.spinner.stopAnimating()
        }
    }
    
    func updateUserInterface() {
        self.tableView.reloadData()
    }
    
    func prepareNavigation(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    
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
                let data = viewModel.cellData(at: indexPath)
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
