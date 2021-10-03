//
//  LocationManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/27/21.
//

import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManagerDidUpdateCurrentCity(_ cityData: CityData)
}

class LocationManager: NSObject {
    
    var currentCityData: CityData? {
        didSet {
            completionLocatingHandler = nil
        }
    }
    weak var delegate: LocationManagerDelegate?
    
    private lazy var cityManager: CityManager = CityManager()
    private let clLocationManager: CLLocationManager
    private var completionLocatingHandler: (() -> Void)?
        
    override init() {
        clLocationManager = CLLocationManager()
        super.init()
        clLocationManager.delegate = self
    }    
}

extension LocationManager {
    func performLocating(completionHandler: (() -> Void)?) {
        self.completionLocatingHandler = completionHandler
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways:
                clLocationManager.requestLocation()
                return
            case .authorizedWhenInUse:
                clLocationManager.requestLocation()
                return
            case .denied:
                print("Sorry, location denied go to the settings and set it manually.")
            case .notDetermined:
                clLocationManager.requestWhenInUseAuthorization()
            case .restricted:
                clLocationManager.requestWhenInUseAuthorization()
            @unknown default:
                fatalError()
            }
        }
        self.completionLocatingHandler = nil
        completionHandler?()
        return
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        print(locations)
        guard let location = locations.first else {
            return
        }
        cityManager.determineNearestCity(by: location,
                                         completionHandler: completionLocatingHandler)
        completionLocatingHandler = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handling error
        completionLocatingHandler?()
        completionLocatingHandler = nil
        print(error)
    }
    
}
