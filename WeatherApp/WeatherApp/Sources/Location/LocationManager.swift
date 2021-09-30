//
//  LocationManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/27/21.
//

import CoreLocation

protocol LocationManagerDelegate: class {
    func didUpdateCurrentCity(_ cityData: CityData)
}

class LocationManager: NSObject {
    
    var currentCityData: CityData? {
        didSet {
            completionLocationHandler = nil
        }
    }
    weak var delegate: LocationManagerDelegate?
    
    private let clLocationManager: CLLocationManager
    private var completionLocationHandler: ((CityData?) -> Void)?
        
    override init() {
        clLocationManager = CLLocationManager()
        super.init()
        clLocationManager.delegate = self
    }
    
}

extension LocationManager {
    func performLocateCity() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways:
                clLocationManager.requestLocation()
            case .authorizedWhenInUse:
                clLocationManager.requestLocation()
            case .denied:
                print("Location denied")
            case .notDetermined:
                clLocationManager.requestWhenInUseAuthorization()
                clLocationManager.requestLocation()
            case .restricted:
                print("Location Restricted")
            @unknown default:
                fatalError()
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("locationManager, current status: \(status.rawValue)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        guard let location = locations.first else {
            return
        }
        let handler: ((CityData?) -> Void) = { [weak self] (cityData) in
            guard let self = self,
                  let cityData = cityData,
                  let delegate = self.delegate else {
                return
            }
            delegate.didUpdateCurrentCity(cityData)
        }
        completionLocationHandler = handler
        CityManager.shared.determineNearestCity(by: location, completionHandler: handler)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handling error
        print(error)
    }
    
}
