//
//  SearchResultsViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import UIKit
import CoreData

class SearchResultsViewController: UIViewController {
    
    // MARK: - Properties
    typealias CellType = SubtitleTableViewCell
    var viewModel = CitiesViewModel()
    weak var delegate: Dismissable?
    weak var searchController: UISearchController?
    
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
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.delegate = self
        viewModel.update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardNotificationObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.delegate = nil
        removeKeyboardNotificationObservers()
    }
    
    // MARK: - Helper methods
        
    func configureUI() {
        view.backgroundColor = Asset.accent2.color
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(doneButton)
        view.addSubview(addCityButton)
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
    
    // Keyboard handling propetries
    enum KeyboardState {
        case unknown
        case entering
        case exiting
    }
    private lazy var oldContentInset: UIEdgeInsets = {
        self.tableView.contentInset
    }()
    private lazy var oldOffset: CGPoint = {
        self.tableView.contentOffset
    }()
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.reuseIdentifier, for: indexPath)
        cell.prepareForReuse()
        if let castedCell = cell as? Configurable {
            let model = viewModel.cellModel(at: indexPath)
            castedCell.configure(data: model)
        }
        if item.isChosen {
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = viewModel.item(at: indexPath)
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

// Keyboard handling methods
extension SearchResultsViewController {
    
    func addKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardState(for dictionary: [AnyHashable: Any], in view: UIView?) -> (KeyboardState, CGRect?) {
        
        guard var rectOld = dictionary[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
              var rectNew = dictionary[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let view = view else {
            print("Something goes wrong")
            return (KeyboardState.unknown, CGRect.zero)
        }
        var keyboardState: KeyboardState = .unknown
        var newRect: CGRect?
        let co = UIScreen.main.coordinateSpace
        rectOld = co.convert(rectOld, to: view)
        rectNew = co.convert(rectNew, to: view)
        newRect = rectNew
        if !rectOld.intersects(view.bounds) && rectNew.intersects(view.bounds) {
            keyboardState = .entering
        }
        if rectOld.intersects(view.bounds) && !rectNew.intersects(view.bounds) {
            keyboardState = .exiting
        }
        return (keyboardState, newRect)
    }
    
    @objc func keyboardShow(_ notification: Notification) {
        let dict = notification.userInfo!
        let (state, rnew) = keyboardState(for: dict, in: self.tableView)
        if state == .unknown {
            return
        } else if state == .entering {
            self.oldContentInset = self.tableView.contentInset
            self.oldOffset = self.tableView.contentOffset
        }
        if let rnew = rnew {
            let height = rnew.intersection(self.tableView.bounds).height
            self.tableView.contentInset.bottom = height
        }
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        let dict = notification.userInfo!
        let (state, _) = keyboardState(for: dict, in: self.tableView)
        if state == .exiting {
            self.tableView.contentOffset = self.oldOffset
            self.tableView.contentInset = self.oldContentInset
        }
    }
}

extension SearchResultsViewController: NSFetchedResultsControllerDelegate, Updatable {
    
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

extension SearchResultsViewController {
    @objc
    private func dismissTapped() {
        delegate?.dismiss(animated: true)
    }
    
    @objc func addCityHandle() {
        let storyboard = UIStoryboard(name: "CityDetailViewController", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            vc.modalPresentationStyle = .pageSheet
            present(vc, animated: true, completion: nil)
        }
    }
}
