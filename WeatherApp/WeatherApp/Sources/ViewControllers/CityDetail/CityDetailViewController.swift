//
//  PlaceOrderViewController.swift
//  RepairService
//
//  Created by  Buxlan on 9/16/21.
//

import UIKit
import CoreData

enum TextFieldState {
    case ok
    case notOk
}

class CityDetailViewController: UIViewController {
        
    // MARK: Properties
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var cityNameTextField: UITextField!
    @IBOutlet var cityIdTextField: UITextField!
    @IBOutlet var longitudeTextField: UITextField!
    @IBOutlet var latitudeTextField: UITextField!
    @IBOutlet var doneButton: UIButton!
    
    private var managedObjectContext: NSManagedObjectContext = CoreDataManager.shared.mainObjectContext
    private lazy var city: City = {
        let city = City(context: self.managedObjectContext)
        city.isChosen = true
        return city
    }()
    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        discard()
    }
    
    // MARK: Helper functions
    func configureUI() {
        title = L10n.Screens.newCity
        view.backgroundColor = Asset.accent2.color
        scrollView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        cityNameTextField.autocapitalizationType = .sentences
        cityNameTextField.autocorrectionType = .default
        cityIdTextField.keyboardType = .decimalPad
        longitudeTextField.keyboardType = .decimalPad
        latitudeTextField.keyboardType = .decimalPad
        
        cityNameTextField.delegate = self
        longitudeTextField.delegate = self
        latitudeTextField.delegate = self
        cityIdTextField.delegate = self
        configureConstraints()
    }
    
    private func configureConstraints() {
        let constraints: [NSLayoutConstraint] = [

            scrollView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -64),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            stackView.heightAnchor.constraint(lessThanOrEqualToConstant: 304),
            
//            cityNameTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            cityNameTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -64),
//            cityNameTextField.bottomAnchor.constraint(equalTo: longitudeTextField.topAnchor, constant: -16),
//            cityNameTextField.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 32),
//            cityNameTextField.heightAnchor.constraint(equalToConstant: 44),
//
//            longitudeTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            longitudeTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -64),
//            longitudeTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            longitudeTextField.heightAnchor.constraint(equalToConstant: 44),
//
//            latitudeTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            latitudeTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -64),
//            latitudeTextField.topAnchor.constraint(equalTo: longitudeTextField.bottomAnchor, constant: 16),
//            latitudeTextField.heightAnchor.constraint(equalToConstant: 44),
//            latitudeTextField.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -32),
            
            doneButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            doneButton.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 44),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func configureData() {
        cityNameTextField.text = city.name
        latitudeTextField.text = "\(city.coordLatitude)"
        longitudeTextField.text = "\(city.coordLongitude)"
    }
    
    private func discard() {
        let context = CoreDataManager.shared.mainObjectContext
        if !context.hasChanges { return }
        context.perform {
            do {
                context.delete(self.city)
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func save() {
        let context = CoreDataManager.shared.mainObjectContext
        if !context.hasChanges { return }
        context.perform {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func saveHandle(_ sender: Any) {
        if city.name.isEmpty {
            updateAppearance(for: cityNameTextField, state: .notOk)
            return
        }
        if city.id == 0 {
            updateAppearance(for: cityIdTextField, state: .notOk)
            return
        }
        save()
    }
    
    private func updateAppearance(for textField: UITextField, state: TextFieldState) {
        switch state {
        case .ok:
            textField.backgroundColor = .white
        default:
            textField.backgroundColor = Asset.accent2.color.withAlphaComponent(0.25)
            textField.resignFirstResponder()
            textField.shake()
        }
    }
    
    @discardableResult
    private func updateViewModel(by textField: UITextField) -> TextFieldState {
        switch textField {
        case cityNameTextField:
            if let text = textField.text,
               !text.isEmpty {
                city.name = text
                return .ok
            }
        case cityIdTextField:
            if let text = textField.text,
               !text.isEmpty,
               let id = Int32(text) {
                city.id = id
                return .ok
            }
        case latitudeTextField:
            if let text = textField.text,
               !text.isEmpty,
               let coord = Float(text) {
                city.coordLatitude = coord
            }
            return .ok
        case longitudeTextField:
            if let text = textField.text,
               !text.isEmpty,
               let coord = Float(text) {
                city.coordLongitude = coord
            }
            return .ok
        default:
            return .notOk
        }
        return .notOk
    }
    
    // Handling keyboard state
    enum KeyboardState {
        case unknown
        case entering
        case exiting
    }
    private lazy var oldContentInset: UIEdgeInsets = {
        self.scrollView.contentInset
    }()
    private lazy var oldOffset: CGPoint = {
        self.scrollView.contentOffset
    }()
}

// MARK: - Keyboard state handling

extension CityDetailViewController {
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
        let (state, rnew) = keyboardState(for: dict, in: self.scrollView)
        if state == .unknown {
            return
        } else if state == .entering {
            self.oldContentInset = self.scrollView.contentInset
            self.oldOffset = self.scrollView.contentOffset
        }
        if let rnew = rnew {
            let height = rnew.intersection(self.scrollView.bounds).height
            self.scrollView.contentInset.bottom = height
        }
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        let dict = notification.userInfo!
        let (state, _) = keyboardState(for: dict, in: self.scrollView)
        if state == .exiting {
            self.scrollView.contentOffset = self.oldOffset
            self.scrollView.contentInset = self.oldContentInset
        }
    }
}

extension CityDetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let state = updateViewModel(by: textField)
        updateAppearance(for: textField, state: state)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if reason != .committed {
            return
        }
        switch textField {
        case cityNameTextField:
            cityIdTextField.becomeFirstResponder()
        case cityIdTextField:
            latitudeTextField.becomeFirstResponder()
        case latitudeTextField:
            longitudeTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(true)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        switch textField {
        case latitudeTextField:
            guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            return true
        case longitudeTextField:
            guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            return true
        default:
            return true
        }
    }
    
}
