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

class MapViewController: MMAnimableViewController {
    
    //MARK: - Properties
    private let databaseManager: DatabaseManager
    
    private let map = MKMapView()
    private let locationManager = CLLocationManager()

    private var clusteredMurals = PublishSubject<[Mural]>()
    private var disposeBag = DisposeBag()
    
    lazy private var clusteredCollectionView: UICollectionView = {
        let padding: CGFloat = 20
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MMFavoritesMuralCollectionCell.self, forCellWithReuseIdentifier: MMFavoritesMuralCollectionCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)
        collectionView.layer.cornerRadius = 20
        collectionView.alpha = 0.0
        return collectionView
    }()
    
   
    //MARK: - Initialization
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMuralsItemsObserver()
        addLastDeletedMuralObserwer()
        addLastEditedMuralObserver()
        addMapPinButtonTappedObserver()
        bindClusteredCollectionView()
        
        layoutUI()
        configureLocationManager()
        configureMapView()
        setupUserTrackingButton()
    }
    
    
    //MARK: - Set up
    private func configureLocationManager() {
        locationManager.delegate = self
    }
    
    
    private func configureMapView() {
        map.delegate = self
        map.showsUserLocation = true
        map.pointOfInterestFilter = .excludingAll
        map.userTrackingMode = .none
    }
    
    
    private func layoutUI() {
        view.addSubviews(map, clusteredCollectionView)
        clusteredCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        map.pinToEdges(of: self.view)
        
        NSLayoutConstraint.activate([
            clusteredCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            clusteredCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clusteredCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clusteredCollectionView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    
    private func setupUserTrackingButton() {
        let button = MKUserTrackingButton(mapView: map)
        button.layer.backgroundColor = MMColors.orangeDark.cgColor
        button.layer.borderColor = MMColors.orangeLight.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.tintColor = MMColors.violetDark
    
        button.translatesAutoresizingMaskIntoConstraints = false
        map.addSubview(button)

        NSLayoutConstraint.activate([button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                                     button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        ])
    }
    
    
    //MARK: - Logic
    private func setMapRegion(with coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                       longitude: coordinate.longitude),
                                                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
    }

    
    //MARK: - Binding
    private func addMuralsItemsObserver() {
        databaseManager.muralItems
            .subscribe(onNext: { [weak self] murals in
                guard let self = self else { return }
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
            .disposed(by: disposeBag)
    }
    
    
    private func addLastDeletedMuralObserwer() {
        databaseManager.lastDeletedMuralID
            .subscribe(onNext: { [weak self] muralID in
                guard let self = self else { return }
                
                guard let annottionToRemove = self.map.annotations.first(where: { $0.title == muralID }) else { return }
                self.map.removeAnnotation(annottionToRemove)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func addLastEditedMuralObserver() {
        databaseManager.lastEditedMuralID
            .subscribe(onNext: { [weak self] mural in
                guard let self = self else { return }
                self.databaseManager.murals.removeAll(where: { $0.docRef == mural.docRef })
                
                guard let annottionToRemove = self.map.annotations.first(where: { $0.title == mural.docRef }) else { return }
                self.map.removeAnnotation(annottionToRemove)
                
                self.databaseManager.murals.append(mural)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func addMapPinButtonTappedObserver() {
        databaseManager.mapPinButtonTappedOnMural
            .subscribe(onNext: { [weak self] mural in
                guard let self = self else { return }
                
                self.setMapRegion(with: CLLocationCoordinate2D(latitude: mural.latitude, longitude: mural.longitude))
            })
            .disposed(by: disposeBag)
    }
    
    
    private func bindClusteredCollectionView() {
        clusteredMurals
            .bind(to:
                clusteredCollectionView.rx.items(cellIdentifier: MMFavoritesMuralCollectionCell.identifier,
                                        cellType: MMFavoritesMuralCollectionCell.self)) { indexPath, mural, cell in
                cell.set(mural: mural)
            }
            .disposed(by: disposeBag)
        
        clusteredCollectionView.rx.itemSelected.subscribe(onNext: { [weak self ]index in
            guard let self = self else { return }
            self.selectedCell = self.clusteredCollectionView.cellForItem(at: index) as? MMFavoritesMuralCollectionCell
            self.cellShape = .roundedCorners(radius: 20)
            self.setSnapshotsForAnimation()
        })
        .disposed(by: disposeBag)
        
        clusteredCollectionView.rx.modelSelected(Mural.self).subscribe(onNext: { [weak self] mural in
            guard let self = self else { return }
            self.prepereAndPresentDetailVCWithAnimation(mural: mural, databaseManager: self.databaseManager)
        })
        .disposed(by: disposeBag)
    }
}

//MARK: - Ext: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location was updated.")
        guard let location = locations.first else { return }
        setMapRegion(with: location.coordinate)
        print("Map region was set.")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("🟡 CLAuthorizationStatus is: notDetermined")
            if databaseManager.currentUser != nil {
                manager.requestWhenInUseAuthorization()
            }
        case .restricted, .denied :
            print("🟡 CLAuthorizationStatus is: denied or restricted")
            break
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            print("🟡 CLAuthorizationStatus is: authorizedAlways or authorizedWhenInUse or authorized")
            locationManager.requestLocation()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        @unknown default:
            break
        }
    }
}
//MARK: - Ext: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let item = annotation as? MKPointAnnotation {
            
            guard let thumbnailURL = annotation.subtitle,
                  let docRef = annotation.title else {
                print("🔴 Error geting url and docRef from annotation")
                return nil
            }
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MMAnnotationView.reuseIdentifier) as? MMAnnotationView
                ?? MMAnnotationView(annotation: item, reuseIdentifier: MMAnnotationView.reuseIdentifier) as MMAnnotationView
            
            annotationView.clusteringIdentifier = "muralItemClustered"
            annotationView.setImage(thumbnailURL: thumbnailURL!, docRef: docRef!)
            
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
            
            self.selectedCell = view as? MMAnnotationView
            self.cellShape = .circle(radius: RadiusValue.mapPinRadiusValue)
            self.clusteredCollectionView.alpha = 0.0
            self.setSnapshotsForAnimation()
            
            self.showLoadingView(message: nil)
            let destVC = MuralDetailsViewController(muralItem: muralItem, databaseManager: databaseManager, presentingVCTitle: self.title)
            destVC.modalPresentationStyle = .fullScreen
            destVC.transitioningDelegate = self
            
            ImagesManager.shared.downloadImage(from: muralItem.imageURL, imageType: .fullSize, name: muralItem.docRef) { image in
                DispatchQueue.main.async {
                    destVC.imageView.image = image
                    self.dismissLoadingView()
                    self.present(destVC, animated: true)
                }
                print("🔵 Zdjęcie pobrane")
            }
            
            mapView.deselectAnnotation(nil, animated: true)
        }
        
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            UIView.animate(withDuration: 0.1) { self.clusteredCollectionView.alpha = 1.0 }
            var murals = [Mural]()
            for annotation in clusterAnnotation.memberAnnotations {
                if let mural = databaseManager.murals.first(where: { $0.docRef == annotation.title }) {
                    murals.append(mural)
                }
            }
            clusteredMurals.onNext(murals)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Odtapnięto \(view)")
        clusteredMurals.onNext([])
        self.clusteredCollectionView.alpha = 0
    }
    
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            print("🟡 CLAuthorizationStatus after mode change is: notDetermined")
            if databaseManager.currentUser != nil {
                locationManager.requestWhenInUseAuthorization()
            }
        case .restricted, .denied :
            print("🟡 CLAuthorizationStatus is after mode change: denied or restricted")
            self.presentMMAlert(title: "Brak uprawnień", message: "Aby wyświetlić swoją lokalizację na mapie musisz wyrazić zgodę na używanie Twojej lokalizacji. Przejdź do Ustawienia > MapaMurali i wyraź zgodę.", buttonTitle: "Ok")
            if map.userTrackingMode != .none {
                map.userTrackingMode = .none
            }
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            break
        @unknown default:
            break
        }
    }
}
