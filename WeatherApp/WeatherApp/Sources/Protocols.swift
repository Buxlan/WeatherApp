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
    func didChangeTableViewState(new state: UserInterfaceStatus)
}

protocol ViewStateDelegate: class {
    func didChangeViewState(new state: UserInterfaceStatus)
}

protocol CurrentCityDelegate: class {
    func didChangeCurrentCity(new value: CityData?)
}
