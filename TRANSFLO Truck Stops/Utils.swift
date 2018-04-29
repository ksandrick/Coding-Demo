//
//  Utils.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/29/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import Foundation

class Utils {
    
    class func metersIn(miles:Double) -> Double {
        return miles * Distances.metersInAMile
    }
    
    class func milesIn(meters:Double) -> Double {
        return meters * Distances.milesInAMeter
    }
    
}
