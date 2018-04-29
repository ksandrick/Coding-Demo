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
            for truckStop in truckStops {
                print(truckStop.name)
                self.mapView.addAnnotations(truckStops)
            }
        }
    }
    
    var locationManager:CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    
    let defaultRadius: CLLocationDistance = 100.0
    let metersInAMile: Double = 1609.344
    let milesInAMeter: Double = 0.000621371192
//    let regionRadius: CLLocationDistance = 100
//    let initialLocation = CLLocation(latitude: 36.665115, longitude: -121.636536)

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
        let radiusInMiles = metersInAMile * defaultRadius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radiusInMiles, radiusInMiles)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            //view.image = UIImage(named: "truckPin")
        }
        return view
    }
    
}
