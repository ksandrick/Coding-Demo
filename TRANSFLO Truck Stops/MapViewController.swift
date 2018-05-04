//
//  MapViewController.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/25/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
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
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineLocationStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}

extension MapViewController: CLLocationManagerDelegate {

    func determineLocationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                case .denied, .restricted:
                    //Show alert sending them to settings
                    showSettingsAlert()
                case .authorizedAlways, .authorizedWhenInUse:
                    startLocationManager()
            }
        } else {
            print("Location services are not enabled")
        }
    }
 
    func showSettingsAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Location Services Required", comment:"" ), message: NSLocalizedString("Open user settings", comment:"" ), preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "Settings", style: .default) {
            (result : UIAlertAction) -> Void in
            UIApplication.shared.open(NSURL(string:UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:"" ), style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("User location did change")
        manager.stopUpdatingLocation()
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        centerMapOnLocation(location: userLocation)
        
        if !isTracking { locationManager.stopUpdatingLocation() }
        
        TruckStop.retrieveTruckStops(location: userLocation) { truckStops in
            self.truckStops = truckStops
        }
    }
 
}

extension MapViewController: MKMapViewDelegate {
    
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
        let buttonTitle = isTracking ? NSLocalizedString("Tracking: On", comment:"" ) : NSLocalizedString("Tracking: Off", comment:"" )
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        recolorSelectedPin(view: view, toColor: UIColor.green)
        performSegue(withIdentifier: "TruckStopSegue", sender: view)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        recolorSelectedPin(view: view, toColor: UIColor.orange)
    }
    
    func recolorSelectedPin(view: MKAnnotationView, toColor: UIColor) {
        if let curAnnotation = view.annotation as? TruckStop {
            if let markerView = mapView.view(for: curAnnotation) as? MKMarkerAnnotationView {
                markerView.markerTintColor = toColor
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let userAnnotationView = mapView.view(for: mapView.userLocation)
        userAnnotationView?.isEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "truckStopMarker"
        
        if annotation is MKUserLocation {
            let locationView = mapView.view(for: annotation) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            locationView.markerTintColor = UIColor.blue
            locationView.glyphImage = UIImage.init(named: "truck")
            return locationView
        }
        
        guard let curAnnotation = annotation as? TruckStop else { return nil }
        var pinView: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as?  MKMarkerAnnotationView {
            dequeuedView.annotation = curAnnotation
            pinView = dequeuedView
        } else {
            pinView = MKMarkerAnnotationView(annotation: curAnnotation, reuseIdentifier: identifier)
            pinView.canShowCallout = false
            pinView.markerTintColor = UIColor.orange
            pinView.glyphImage = UIImage.init(named: "gasPump")
        }
        return pinView
    }
}
