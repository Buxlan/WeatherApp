//
//  Protocols.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/1/21.
//

import UIKit

protocol Observer: class {
    func notify()
}

protocol Updatable: class {
    func updateUserInterface()
}

protocol Navigatable: class {
    func prepareNavigation(viewController: UIViewController)
}

protocol ViewModelStateDelegate: class {
    func didChangeTableViewState(_ state: UserInterfaceStatus)
}

protocol ViewStateDelegate: class {
    func didChangeViewState(_ state: UserInterfaceStatus)
}

protocol CurrentCityDelegate: class {
    func didChangeCurrentCity(_ city: CityData?)
}

protocol LocationManagerDelegate: class {
    func locationManagerDidUpdateCurrentCity(_ cityData: CityData)
}

protocol Configurable {
    static var reuseIdentifier: String { get }
    func configure(data: DataModel)
}
extension Configurable {
    static var reuseIdentifier: String { String(describing: Self.self) }
}

protocol Dismissable: class {
    func dismiss(animated: Bool)
}
