//
//  LocationManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/27/21.
//

import CoreLocation

class LocationManager: NSObject {
    
    let clLocationManager: CLLocationManager
    
    static let shared: LocationManager = LocationManager()
    
    override init() {
        clLocationManager = CLLocationManager()
        super.init()
        clLocationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            clLocationManager.requestWhenInUseAuthorization()
            clLocationManager.startUpdatingLocation()
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    clLocationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        guard let location = locations.first else {
            return
        }
        CityManager.shared.determineCity(by: location)
        clLocationManager.stopUpdatingLocation()
    }
    
}
