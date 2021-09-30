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
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch cell {
        case let cell as Configurable:
            cell.configure(data: item)
        default:
            print("Strange cell (is not Configurable)")
        }
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

extension DailyWeatherViewController: Updatable {
    func update() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.spinner.startAnimating()
            self.tableView.reloadData()
        }
    }
}
