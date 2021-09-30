//
//  SearchResultsViewController.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/22/21.
//

import UIKit
import CoreData

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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.prepareForReuse()
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "Id: \(item.id)"
        cell.accessoryType = item.isChosen ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = viewModel.item(at: indexPath)
        if item.isChosen {
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
    }
    
    func configureUI() {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.accessibilityIdentifier = "Search"
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "cell")
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

extension SearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let filter = searchController.searchBar.text ?? ""
        viewModel.update(with: filter)
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
    
    func update() {
        tableView.reloadData()
    }
    
}
