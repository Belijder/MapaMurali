//
//  MapViewLocationDelegate.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 02/04/2023.
//

import Foundation
import MapKit

protocol LocationUpdating {
    func dismissToRootVC()
    func setMapRegion(with coordinate: CLLocationCoordinate2D)
}

class MapViewLocationDelegate: NSObject, CLLocationManagerDelegate {
    
    let databaseManager: DatabaseManager!
    var parentController: LocationUpdating?
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        parentController?.setMapRegion(with: location.coordinate)
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            if databaseManager.currentUser != nil {
                manager.requestWhenInUseAuthorization()
            }
        case .restricted, .denied :
            break
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            manager.requestLocation()
            parentController?.dismissToRootVC()
        @unknown default:
            break
        }
    }
}
