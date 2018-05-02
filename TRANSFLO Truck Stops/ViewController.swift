//
//  ViewController.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/25/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var truckStops: [TruckStop] = [] {
        didSet {
            self.mapView.addAnnotations(truckStops)
        }
    }
    
    var locationManager:CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        determineLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let radiusInMeters = Utils.metersIn(miles: Distances.defaultRadius)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radiusInMeters, radiusInMeters)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let currentMapLocation = mapView.centerCoordinate
        let location:CLLocation = CLLocation(latitude: currentMapLocation.latitude, longitude: currentMapLocation.longitude)
        TruckStop.retrieveTruckStops(radius: mapView.currentRadius(), location: location) { truckStops in
            self.truckStops = truckStops
        }
    }
    
    @IBAction func unwindToMainViewController(sender: UIStoryboardSegue) {
        if let currentTruckStop = (sender.source as? TruckStopViewController)?.truckStop {
            mapView.deselectAnnotation(currentTruckStop, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let annotationView = sender as? MKAnnotationView
        let truckStop = annotationView?.annotation as? TruckStop
        if let modalViewController = segue.destination as? TruckStopViewController {
            modalViewController.truckStop = truckStop
            modalViewController.userLocation = mapView.userLocation.location
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let truckStop = view.annotation as? TruckStop {
            performSegue(withIdentifier: "TruckStopSegue", sender: view)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("User location did change")
        manager.stopUpdatingLocation()
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        centerMapOnLocation(location: userLocation)
        TruckStop.retrieveTruckStops(location: userLocation) { truckStops in
            self.truckStops = truckStops
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let annotation = annotation as? TruckStop else { return nil }
        let identifier = "truckStopMarker"
        var pinView: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as?  MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            pinView = dequeuedView
        } else {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)//MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.canShowCallout = false
            pinView.markerTintColor = UIColor.orange
            pinView.glyphText = "T"
        }
        return pinView

    }
    
}
