//
//  Utils.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/29/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import Foundation

extension Double {
    func toMeters() -> Double {
        return self * Distances.metersInAMile
    }
    
    func toMiles() -> Double {
        return self * Distances.milesInAMeter
    }
}
