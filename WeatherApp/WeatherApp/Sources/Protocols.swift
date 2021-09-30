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
    func update()
}

protocol Navigatable: class {
    func prepareNavigation(viewController: UIViewController)
}

protocol CurrentCityDelegate {
    func didChangeCurrentCity(new value: CityData?)
}
