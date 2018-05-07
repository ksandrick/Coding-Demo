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

    private var resetWorkItem: DispatchWorkItem?
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.mapType = mapType
        }
    }
    
    @IBOutlet weak var mapTypeControl: UISegmentedControl! {
        didSet {
            let typeVal: Int
            switch mapType {
                case .standard:
                typeVal = 0
            case .satellite:
                typeVal = 1
            default:
                typeVal = 0
            }
            mapTypeControl.selectedSegmentIndex = typeVal
        }
    }
    
    @IBOutlet weak var mapTrackingButton: UIButton! {
        didSet {
            configureTrackingButtonFor(state: isTracking)
        }
    }
    
    var truckStops: [TruckStop] = []

    struct K {
        static let trackingKey = "Tracking"
        static let mapTypeKey = "MapType"
    }
    
    let userDefaults = UserDefaults.standard
    
    var isFirstTime: Bool = true
    var isTracking: Bool {
        get {
            return userDefaults.bool(forKey: K.trackingKey)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: K.trackingKey)
        }
    }
    
    var mapType: MKMapType {
        get {
            guard let savedMapType = userDefaults.value(forKey: K.mapTypeKey) as? UInt else {
                return MKMapType.standard
            }
            return MKMapType(rawValue: savedMapType)!
        }
        set(newType) {
            userDefaults.set(newType.rawValue, forKey: K.mapTypeKey)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineLocationStatus()
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
            handleAuthorization(status: CLLocationManager.authorizationStatus())
        } else {
            print("Location services are not enabled")
            showSettingsAlert()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorization(status: status)
    }
    
    func handleAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showSettingsAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationManager()
        }
    }
 
    func showSettingsAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Location Services Required", comment: "" ), message: NSLocalizedString("Open user settings", comment: "" ), preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "Settings", style: .default) {
            (result: UIAlertAction) -> Void in
            UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "" ), style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = Distances.defaultFilterDistance
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("User location did change")
        let userLocation: CLLocation = locations.last! as CLLocation

        if isFirstTime {
            isFirstTime = false
            manager.stopUpdatingLocation()
            reCenterMapOnLocation(userLocation, withReset: true)
        } else {
            if isTracking {
                reCenterMapInSeconds(Timing.defaultMinimumDelay)
            } else {
                manager.stopUpdatingLocation()
            }
        }
    }
 
}

extension MapViewController: MKMapViewDelegate {
    
    @IBAction func mapTypeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapType = .standard
        case 1:
            mapType = .satellite
        default:
            mapType = .standard
        }
        mapView.mapType = mapType
    }
    
    @IBAction func toggleTracking(_ sender: UIButton) {
        isTracking = !isTracking
        configureTrackingButtonFor(state: isTracking)
        if isTracking { locationManager.startUpdatingLocation() }
    }
    
    func configureTrackingButtonFor(state: Bool) {
        let buttonTitle = state ? NSLocalizedString("Tracking: On", comment: "" ) : NSLocalizedString("Tracking: Off", comment: "" )
        mapTrackingButton.setTitle(buttonTitle, for: .normal)
    }
    
    @IBAction func resetMap() {
        if let currentUserLocation = mapView.userLocation.location {
            reCenterMapOnLocation(currentUserLocation, withReset: true)
        }
    }
    
    func reCenterMapOnUser() {
        if let currentUserLocation = mapView.userLocation.location {
            reCenterMapOnLocation(currentUserLocation, withReset: false)
        }
    }
    
    func reCenterMapOnLocation(_ location: CLLocation, withReset: Bool) {
        let radius = withReset ? Distances.defaultRadius : mapView.currentRadius()
            centerMapOnLocation(location, radius: radius)
    }
    
    func reCenterMapInSeconds(_ seconds: Double) {
        resetWorkItem = DispatchWorkItem {[weak self] in
            self?.reCenterMapOnUser()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: resetWorkItem!)
    }
    
    func centerMapOnLocation(_ location: CLLocation,
                             radius: Double = Distances.defaultRadius) {
        let radiusInMeters = radius.toMeters()
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radiusInMeters, radiusInMeters)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        resetWorkItem?.cancel()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let currentMapLocation = mapView.centerCoordinate
        let location: CLLocation = CLLocation(latitude: currentMapLocation.latitude, longitude: currentMapLocation.longitude)

        TruckStop.retrieveTruckStops(radius: mapView.currentRadius(), location: location) { truckStops in
            let newTruckStops = truckStops.newest(from: self.truckStops)
            DispatchQueue.main.async {
                self.mapView.addAnnotations(newTruckStops)
            }

            var accumulatedTruckStops = self.truckStops + truckStops
            accumulatedTruckStops = Array(Set(accumulatedTruckStops))
            self.truckStops = accumulatedTruckStops
        }

        if isTracking { reCenterMapInSeconds(Timing.inactivityDelay) }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        recolorSelectedPin(view: view, toColor: UIColor.green)
        if let location = view.annotation?.coordinate {
            mapView.setCenter(location, animated: true)
        }
        performSegue(withIdentifier: "TruckStopSegue", sender: view)
        
        if isTracking {
            resetWorkItem?.cancel()
            reCenterMapInSeconds(Timing.detailInactivityDelay)
        }
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
        if annotation is MKUserLocation {
            let locationView = mapView.view(for: annotation) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
            locationView.markerTintColor = UIColor.blue
            locationView.glyphImage = UIImage.init(named: "truck")
            return locationView
        }
        
        guard let curAnnotation = annotation as? TruckStop else { return nil }
        let identifier = "truckStopMarker"
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
