//
//  ViewController.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/25/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    static let defaultRadius: CGFloat = 100.0;

    override func viewDidLoad() {
        super.viewDidLoad()
        let latitude: CLLocationDegrees = 36.665115
        let longitude: CLLocationDegrees = -121.636536
        let searchLocation = CLLocation.init(latitude: latitude, longitude: longitude)
        TruckStop.retrieveTruckStops(location: searchLocation) { truckStops in
            for truckStop in truckStops {
                print(truckStop.name)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

