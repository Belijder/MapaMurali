//
//  ViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 28/07/2022.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift
import QuartzCore

class MapViewController: UIViewController {
    
    let map = MKMapView()
    var databaseManager: DatabaseManager
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMuralsItemsObserver()
        setMapConstraints()
        configureMapView()
        configureLocationManager()
        databaseManager.fetchMuralItemsFromDatabase()
    
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
        //map.register(MMAnnotationView.self, forAnnotationViewWithReuseIdentifier: MMAnnotationView.reuseIdentifier)
    }
    
    
    func setMapRegion(with coordinate: CLLocationCoordinate2D) {
        map.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                       longitude: coordinate.longitude),
                                                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
    
    func addMuralsItemsObserver() {
        databaseManager.muralItems
            .subscribe(onNext: { murals in
                for mural in murals {
                    let pin = MKPointAnnotation()
                    pin.title = mural.adress
                    pin.subtitle = mural.thumbnailURL
                    pin.coordinate = CLLocationCoordinate2D(latitude: mural.latitude, longitude: mural.longitude)
                    self.map.addAnnotation(pin)
                    print("Dodano mural")
                }
            })
            .disposed(by: bag)
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //Here is annotation for userlogaction. To manage later...
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MMAnnotationView.reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MMAnnotationView(annotation: annotation, reuseIdentifier: MMAnnotationView.reuseIdentifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        
        return annotationView
    }
}

