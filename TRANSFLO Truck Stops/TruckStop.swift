//
//  TruckStop.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/25/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import Foundation

struct TruckStop {
    let name: String
    let city: String
    let state: String
    let country: String
    let zip: String
    let rawLine1: String
    let rawLine2: String
    let rawLine3: String
    let location: (latitude: Double, longitude: Double)
}

extension TruckStop {
    init?(json: [String: Any]) {
        // Handle required fields
        guard let name = json["name"] as? String,
            let latitude = json["lat"] as? String,
            let longitude = json["lng"] as? String
        else{
            return nil
        }
        self.name = name
        self.location = (Double(latitude)!, Double(longitude)!)
        
        // Extract all others
        self.city = json["city"] as? String ?? ""
        self.state = json["state"] as? String ?? ""
        self.zip = json["zip"] as? String ?? ""
        self.country = json["country"] as? String ?? ""
        self.rawLine1 = json["rawLine1"] as? String ?? ""
        self.rawLine2 = json["rawLine2"] as? String ?? ""
        self.rawLine3 = json["rawLine3"] as? String ?? ""
    }
}
