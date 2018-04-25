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
        retrieveTruckStops()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func retrieveTruckStops(radius: Double = 100.0,
                                        location: CLLocation) {
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
            
            do {
                let results = try JSONSerialization.jsonObject(with: data, options: [])
                print("Result -> \(describing: results)")
                
            } catch {
//                print("Error -> \(describing: error)")
            }
        }
        task.resume()
    }


}

