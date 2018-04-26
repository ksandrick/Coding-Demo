//
//  TruckStop.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/25/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class TruckStop: NSObject, MKAnnotation {
    let name: String
    let city: String
    let state: String
    let country: String
    let zip: String
    let rawLine1: String
    let rawLine2: String
    let rawLine3: String
    let latitude: Double
    let longitude: Double
    let coordinate: CLLocationCoordinate2D
    
    var title: String? {
        return name
    }
    var subtitle: String? {
        return ""
    }

    init?(json: [String: Any]) {
        // Handle required fields
        guard let name = json["name"] as? String,
            let latitude = json["lat"] as? String,
            let longitude = json["lng"] as? String
        else{
            return nil
        }
        self.name = name
        self.latitude = Double(latitude)!
        self.longitude = Double(longitude)!
        self.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        
        // Extract all others
        self.city = json["city"] as? String ?? ""
        self.state = json["state"] as? String ?? ""
        self.zip = json["zip"] as? String ?? ""
        self.country = json["country"] as? String ?? ""
        self.rawLine1 = json["rawLine1"] as? String ?? ""
        self.rawLine2 = json["rawLine2"] as? String ?? ""
        self.rawLine3 = json["rawLine3"] as? String ?? ""
    }
    
    static func retrieveTruckStops(radius: Double = 100.0,
                            location: CLLocation,
                            completion: @escaping ([TruckStop]) -> Void) {
        let urlString = Services.apiURL + String(format:"%f", radius)
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(Services.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let json: [String: Any] = ["lat": location.coordinate.latitude,
                                   "lng": location.coordinate.longitude]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for general errors
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            var truckStops: [TruckStop] = []
            if let jsonResults = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                if let returnedTruckStops = jsonResults!["truckStops"] as? [Any] {
                    for result in returnedTruckStops {
                        if let truckStop = TruckStop(json: result as! Dictionary<String,Any>) {
                            truckStops.append(truckStop)
//                            print(truckStop)
                        }
                    }
                    completion(truckStops)
                }
            }
        }
        task.resume()
    }
 
}
