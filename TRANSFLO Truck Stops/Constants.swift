//
//  Constants.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/25/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import Foundation

struct Services {
    static let apiURL = "http://webapp.transflodev.com/svc1.transflomobile.com/api/v3/stations/"
    static let apiKey = "amNhdGFsYW5AdHJhbnNmbG8uY29tOnJMVGR6WmdVTVBYbytNaUp6RlIxTStjNmI1VUI4MnFYcEVKQzlhVnFWOEF5bUhaQzdIcjVZc3lUMitPTS9paU8="
}

struct Timing {
    static let defaultMinimumDelay: Double = 0.5
    static let inactivityDelay: Double = 5.0
    static let detailInactivityDelay: Double = 15.0
    static let searchInactivityDelay: Double = 30.0
}

struct Distances {
    static let metersInAMile: Double = 1609.344
    static let milesInAMeter: Double = 0.000621371192
    static let defaultRadius: Double = 100.0
    static let defaultFilterDistance: Double = 100.0
}

extension Double {
    func toMeters() -> Double {
        return self * Distances.metersInAMile
    }
    
    func toMiles() -> Double {
        return self * Distances.milesInAMeter
    }
}

extension Array where Element: Hashable {
    func newest(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.subtracting(otherSet))
    }
}
