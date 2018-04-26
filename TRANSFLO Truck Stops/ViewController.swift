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

class ViewController: UIViewController {
    
    var truckStops: [TruckStop] = [] {
        didSet {
            for truckStop in truckStops {
                print(truckStop.name)
                self.mapView.addAnnotation(truckStop)
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
//    static let defaultRadius: CGFloat = 100.0;
    let regionRadius: CLLocationDistance = 100
    let initialLocation = CLLocation(latitude: 36.665115, longitude: -121.636536)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerMapOnLocation(location: initialLocation)
        
        let latitude: CLLocationDegrees = 36.665115
        let longitude: CLLocationDegrees = -121.636536
        let searchLocation = CLLocation.init(latitude: latitude, longitude: longitude)
        
        TruckStop.retrieveTruckStops(location: searchLocation) { truckStops in
            self.truckStops = truckStops
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}

