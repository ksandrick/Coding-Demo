//
//  MapView+Radius.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/29/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }
    func topLeftCoordinate() -> CLLocationCoordinate2D {
        return convert(CGPoint.zero, toCoordinateFrom: self)
    }
    
    public func currentRadius() -> Double {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let referenceCoordinate = self.topLeftCoordinate()
        let referenceLocation = CLLocation(latitude: referenceCoordinate.latitude, longitude: referenceCoordinate.longitude)
        let distance = centerLocation.distance(from: referenceLocation)
        return distance.toMiles()
    }
}
