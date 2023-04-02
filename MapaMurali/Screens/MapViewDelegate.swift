//
//  MapViewDelegate.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 31/03/2023.
//

import Foundation
import MapKit

protocol MapViewPresenting {
    func presentDetailVC(muralItem: Mural, cell: MKAnnotationView)
    func didSelectClusteredAnnotation(clusterAnnotation: MKClusterAnnotation)
    func hideClusteredMuralsCollection()
    func presentNoPermissionsMessage()
}


class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    let databaseManager: DatabaseManager!
    var parentController: MapViewPresenting?
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
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
            
            parentController?.presentDetailVC(muralItem: muralItem, cell: view)
            
            mapView.deselectAnnotation(nil, animated: true)
        }
        
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            parentController?.didSelectClusteredAnnotation(clusterAnnotation: clusterAnnotation)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        parentController?.hideClusteredMuralsCollection()
    }
    
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            if databaseManager.currentUser != nil {
                locationManager.requestWhenInUseAuthorization()
            }
        case .restricted, .denied :
            parentController?.presentNoPermissionsMessage()
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            break
        @unknown default:
            break
        }
    }
}
