//
//  ViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/21/21.
//

// Старался делать согласно паттерна MVVM, применяя правило, что VC должен знать о
// Инстанцируется из пустого storyboard
// Весь интерфейс написан программно.

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
        view.allowsSelectionDuringEditing = false
        view.allowsMultipleSelectionDuringEditing = false
        view.setEditing(false, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = UITableView.automaticDimension
        view.register(MainViewTableCell.self,
                      forCellReuseIdentifier: "cell")
        
        view.tableHeaderView = cityView
        didChangeCurrentCity(new: nil)
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
        viewModel.update()
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
            //navigationController?.navigationBar.compactAppearance = appearance

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
            viewModel.performDetermingCurrentCity()
        }
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

extension MainViewController: Navigatable, Updatable, CurrentCityDelegate {

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
    
    func didChangeCurrentCity(new value: CityData?) {
        var text = L10n.City.unknown
        var detailText = ""
        if let data = value {
            text = data.name
            detailText = "\(data.temp)"
        }
        cityView.configure(data: MainDataModel(text: text,
                                               detailText: detailText))        
        determineLocationButton.stopAnimating()
    }
    
}
