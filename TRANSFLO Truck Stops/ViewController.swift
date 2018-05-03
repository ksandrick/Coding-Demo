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
    
    var isTracking:Bool = false
    var locationManager:CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeControl: UISegmentedControl!
    
    var truckStops: [TruckStop] = [] {
        didSet {
            self.mapView.addAnnotations(truckStops)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        determineLocationStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineLocationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    //Request status
                    print("not determined")
                case .denied:
                    //Show alert sending them to settings
                    showSettingsAlert(title: "", message: "")
                case .restricted:
                    //Unauthorized
                    print("restricted")
                case .authorizedAlways, .authorizedWhenInUse:
                    startLocationManager()
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func showSettingsAlert(title: String, message: String) {
        let alertController = UIAlertController(title: "Location Services Required", message: "Open user settings", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:"" ), style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (result : UIAlertAction) -> Void in
            UIApplication.shared.open(NSURL(string:UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func mapTypeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
    }
    
    @IBAction func toggleTracking(_ sender:UIButton) {
        isTracking = !isTracking
        let buttonTitle = isTracking ? "Tracking: On" : "Tracking: Off"
        sender.setTitle(buttonTitle, for: .normal)
        if isTracking { locationManager.startUpdatingLocation() }
    }
    
    @IBAction func resetMap() {
        if let currentUserLocation = mapView.userLocation.location {
            centerMapOnLocation(location: currentUserLocation)
        }
    }
    
    func centerMapOnLocation(location: CLLocation,
                             radius:Double = Distances.defaultRadius) {
        let radiusInMeters = Utils.metersIn(miles: radius)
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
        performSegue(withIdentifier: "TruckStopSegue", sender: view)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let userAnnotationView = mapView.view(for: mapView.userLocation)
        userAnnotationView?.isEnabled = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("User location did change")
        manager.stopUpdatingLocation()
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        centerMapOnLocation(location: userLocation)
        
        if isTracking {
            
        }else{
            locationManager.stopUpdatingLocation()
        }
        
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
