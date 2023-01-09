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
    
    //MARK: - Properties
    var databaseManager: DatabaseManager
    
    let map = MKMapView()
    let locationManager = CLLocationManager()
    
    var userLocation: CLLocationCoordinate2D?
    var mapIsLocatingUser = true
    
    private var bag = DisposeBag()
    
    //MARK: - Initialization
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMuralsItemsObserver()
        addLastDeletedMuralObserwer()
        addLastEditedMuralObserver()
        addMapPinButtonTappedObserver()
        
        setMapConstraints()
        configureMapView()
        setupUserTrackingButton()
        configureLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestLocation()
    }
    
    //MARK: - Set up
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func configureMapView() {
        map.delegate = self
        map.showsUserLocation = true
        map.pointOfInterestFilter = .excludingAll
        map.userTrackingMode = .followWithHeading
        setMapRegion(with: map.userLocation.coordinate)
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
    
    func setupUserTrackingButton() {
        let button = MKUserTrackingButton(mapView: map)
        button.layer.backgroundColor = MMColors.orangeDark.cgColor
        button.layer.borderColor = MMColors.orangeLight.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.tintColor = MMColors.violetDark
        button.translatesAutoresizingMaskIntoConstraints = false
        map.addSubview(button)
        map.userTrackingMode = .follow

        NSLayoutConstraint.activate([button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                                     button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    //MARK: - Logic
    func setMapRegion(with coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                       longitude: coordinate.longitude),
                                                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
    }

    
    //MARK: - Binding
    func addMuralsItemsObserver() {
        databaseManager.muralItems
            .subscribe(onNext: { murals in
                for mural in murals {
                    if !self.map.annotations.contains(where: { $0.title == mural.docRef }) {
                        let pin = MKPointAnnotation()
                        pin.title = mural.docRef
                        pin.subtitle = mural.thumbnailURL
                        pin.coordinate = CLLocationCoordinate2D(latitude: mural.latitude, longitude: mural.longitude)
                        self.map.addAnnotation(pin)
                        print("Dodano mural")
                    }
                }
            })
            .disposed(by: bag)
    }
    
    func addLastDeletedMuralObserwer() {
        databaseManager.lastDeletedMuralID
            .subscribe(onNext: { muralID in
                guard let annottionToRemove = self.map.annotations.first(where: { $0.title == muralID }) else { return }
                self.map.removeAnnotation(annottionToRemove)
            })
            .disposed(by: bag)
    }
    
    func addLastEditedMuralObserver() {
        databaseManager.lastEditedMuralID
            .subscribe(onNext: { mural in
                self.databaseManager.murals.removeAll(where: { $0.docRef == mural.docRef })
                
                guard let annottionToRemove = self.map.annotations.first(where: { $0.title == mural.docRef }) else { return }
                self.map.removeAnnotation(annottionToRemove)
                
                self.databaseManager.murals.append(mural)
            })
            .disposed(by: bag)
    }
    
    func addMapPinButtonTappedObserver() {
        databaseManager.mapPinButtonTappedOnMural
            .subscribe(onNext: { mural in
                self.setMapRegion(with: CLLocationCoordinate2D(latitude: mural.latitude, longitude: mural.longitude))
            })
            .disposed(by: bag)
    }
}

//MARK: - Extensions
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

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
        
        if let item = annotation as? MKPointAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MMAnnotationView.reuseIdentifier)
                ?? MMAnnotationView(annotation: annotation, reuseIdentifier: MMAnnotationView.reuseIdentifier)
            
            annotationView.annotation = item
            annotationView.clusteringIdentifier = "muralItemClustered"
            
            return annotationView
            
        } else if let cluster = annotation as? MKClusterAnnotation {
            
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: MMAnnotationClusterView.reuseIdentifier)
                ?? MMAnnotationClusterView(annotation: annotation, reuseIdentifier: MMAnnotationClusterView.reuseIdentifier)
            
            clusterView.annotation = cluster
            
            return clusterView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Tapnięto \(view)")
        guard let annotation = view.annotation else { return }
        
        if let annotation = annotation as? MKPointAnnotation {
            guard let docRef = annotation.title else { return }
            guard let index = databaseManager.murals.firstIndex(where: { $0.docRef == docRef }) else { return }
            let muralItem = databaseManager.murals[index]
            let vc = MuralDetailsViewController(muralItem: muralItem, databaseManager: databaseManager)
            vc.title = muralItem.adress
            let nc = UINavigationController(rootViewController: vc)
            
            nc.modalPresentationStyle = .fullScreen
            self.present(nc, animated: true) {
                self.map.deselectAnnotation(view.annotation, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Odtapnięto \(view)")
    }
}

