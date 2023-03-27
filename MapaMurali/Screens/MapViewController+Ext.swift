//
//  MapViewController+Ext.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 27/03/2023.
//

import UIKit
import MapKit


//MARK: - Ext: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        setMapRegion(with: location.coordinate)
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
                return nil
            }
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MMAnnotationView.reuseIdentifier) as? MMAnnotationView
                ?? MMAnnotationView(annotation: item, reuseIdentifier: MMAnnotationView.reuseIdentifier) as MMAnnotationView
            
            annotationView.clusteringIdentifier = "muralItemClustered"
            annotationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
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
            clusteredMurals = murals
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        clusteredMurals = []
        self.clusteredCollectionView.alpha = 0
    }
    
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            if databaseManager.currentUser != nil {
                locationManager.requestWhenInUseAuthorization()
            }
        case .restricted, .denied :
            self.presentMMAlert(title: MMMessages.noPermissionsMessage.title, message: MMMessages.noPermissionsMessage.message, buttonTitle: "Ok")
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
