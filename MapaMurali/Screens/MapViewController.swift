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

final class MapViewController: MMAnimableViewController, MapViewPresenting, LocationUpdating {

    //MARK: - Properties
    let databaseManager: DatabaseManager
    private let mapDelegate: MapViewDelegate
    private let locationManagerDelegate: MapViewLocationDelegate
    
    private let map = MKMapView()
    private let locationManager = CLLocationManager()

    private var clusteredMurals = [Mural]() {
        didSet {
            clusteredMuralsPublisher.onNext(clusteredMurals)
        }
    }
    
    private var clusteredMuralsPublisher = PublishSubject<[Mural]>()
    private var disposeBag = DisposeBag()
    
    lazy private(set) var clusteredCollectionView: UICollectionView = {
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
        mapDelegate = MapViewDelegate(databaseManager: databaseManager)
        locationManagerDelegate = MapViewLocationDelegate(databaseManager: databaseManager)
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
        addLastFavoriteStatusChangeObserver()
        addLastReportedMuralObserver()
        addMapPinButtonTappedObserver()
        bindClusteredCollectionView()
        
        layoutUI()
        configureLocationManager()
        configureMapView()
        setupUserTrackingButton()
    }
    
    
    //MARK: - Set up
    private func configureLocationManager() {
        locationManager.delegate = locationManagerDelegate
        locationManagerDelegate.parentController = self
    }
    
    
    private func configureMapView() {
        map.delegate = mapDelegate
        mapDelegate.parentController = self
        
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
    final func setMapRegion(with coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                       longitude: coordinate.longitude),
                                                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
    }
    
    func presentDetailVC(muralItem: Mural, cell: MKAnnotationView) {
        self.selectedCell = cell as? MMAnnotationView
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
        }
    }
    
    
    func didSelectClusteredAnnotation(clusterAnnotation: MKClusterAnnotation) {
        UIView.animate(withDuration: 0.1) { self.clusteredCollectionView.alpha = 1.0 }
        var murals = [Mural]()
        for annotation in clusterAnnotation.memberAnnotations {
            if let mural = databaseManager.murals.first(where: { $0.docRef == annotation.title }) {
                murals.append(mural)
            }
        }
        clusteredMurals = murals
    }
    
    
    func hideClusteredMuralsCollection() {
        clusteredMurals = []
        self.clusteredCollectionView.alpha = 0
    }
    
    
    func presentNoPermissionsMessage() {
        self.presentMMAlert(title: MMMessages.noPermissionsMessage.title, message: MMMessages.noPermissionsMessage.message, buttonTitle: "Ok")
        if map.userTrackingMode != .none {
            map.userTrackingMode = .none
        }
    }
    
    
    func dismissToRootVC() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
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
    
    
    private func addLastReportedMuralObserver() {
        databaseManager.lastReportedMuralID
            .subscribe(onNext: { [weak self] muralID in
                guard let self = self else { return }
                
                guard let annottionToRemove = self.map.annotations.first(where: { $0.title == muralID }) else { return }
                self.map.removeAnnotation(annottionToRemove)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func addLastFavoriteStatusChangeObserver() {
        databaseManager.lastFavoriteStatusChangeMuralID
            .subscribe(onNext: { [weak self] id in
                guard let self = self else { return }
                if self.clusteredMurals.contains(where: { $0.docRef == id }) {
                    guard let index = self.clusteredMurals.firstIndex(where: { $0.docRef == id }) else {return }
                    guard let newMuralData = self.databaseManager.murals.first(where: { $0.docRef == id }) else { return }
                    self.clusteredMurals.remove(at: index)
                    self.clusteredMurals.insert(newMuralData, at: index)
                }
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
        clusteredMuralsPublisher
            .bind(to:
                clusteredCollectionView.rx.items(cellIdentifier: MMFavoritesMuralCollectionCell.identifier,
                                        cellType: MMFavoritesMuralCollectionCell.self)) { indexPath, mural, cell in
                cell.set(mural: mural, uiImageViewSize: CGSize(width: 120, height: 120))
            }
            .disposed(by: disposeBag)
        
        clusteredCollectionView.rx.itemSelected.subscribe(onNext: { [weak self] index in
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
