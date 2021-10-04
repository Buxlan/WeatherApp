//
//  LocationManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/27/21.
//

import CoreLocation

class LocationManager: NSObject {
    
    var currentCityData: CityData? {
        didSet {
            completionLocatingHandler = nil
        }
    }
    weak var delegate: LocationManagerDelegate?
    
    private lazy var cityManager: CityManager = CityManager()
    private var completionLocatingHandler: (() -> Void)?
    private lazy var locationManager: CLLocationManager? = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    deinit {
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }
    
}

extension LocationManager {
    func performLocating(completionHandler: (() -> Void)?) {
        guard let manager = self.locationManager else {
            completionHandler?()
            return
        }
        self.completionLocatingHandler = completionHandler
        if !CLLocationManager.locationServicesEnabled() {
            print("Location services disabled.")
            self.completionLocatingHandler = nil
            completionHandler?()
        }
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            manager.requestLocation()
            return
        case .authorizedWhenInUse:
            manager.requestLocation()
            return
        case .denied:
            print("Sorry, location denied go to the settings and set it manually.")
            self.completionLocatingHandler = nil
            completionHandler?()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            return
        case .restricted:
            self.completionLocatingHandler = nil
            completionHandler?()
            return
        @unknown default:
            fatalError()
        }        
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.requestLocation()
        } else if status == .notDetermined {
        } else {
            completionLocatingHandler?()
            completionLocatingHandler = nil
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
