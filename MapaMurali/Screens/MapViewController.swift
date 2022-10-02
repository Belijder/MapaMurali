//
//  ViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 28/07/2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let map = MKMapView()
    var databaseManager: DatabaseManager
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapConstraints()
        configureLocationManager()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestLocation()
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func configureMapView() {
        map.delegate = self
    }
    
    
    func setMapRegion(with coordinate: CLLocationCoordinate2D) {
        map.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                       longitude: coordinate.longitude),
                                                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
    
    func setMapConstraints() {
        view.addSubview(map)
        map.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: self.view.topAnchor),
            map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            
        ])
    }
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        databaseManager.fetchMuralItemsFromDatabase()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        setMapRegion(with: location.coordinate)

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
}

