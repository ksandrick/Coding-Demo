//
//  TruckStopViewController.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 4/30/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import UIKit
import CoreLocation

class TruckStopViewController: UIViewController {
    
    public var truckStop: TruckStop?
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceView: UIStackView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var address1View: UIStackView!
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var address2View: UIStackView!
    @IBOutlet weak var address2Label: UILabel!
    @IBOutlet weak var address3View: UIStackView!
    @IBOutlet weak var address3Label: UILabel!
    @IBOutlet weak var phoneView: UIStackView!
    @IBOutlet weak var phoneLabel: UILabel!
    
    public var userLocation : CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        if let name = truckStop?.name {
            nameLabel.text = name
        }else{
            nameView.isHidden = true
        }
        
        let meters = truckStop?.distance(location: userLocation) ?? 0
        let miles = Distances.milesInAMeter * meters
        let distance = String(format:"%.1f miles from current location",miles)
        distanceLabel.text = distance
        
        address1Label.text = truckStop?.rawLine1
        if let city = truckStop?.city, let state = truckStop?.state, let zip = truckStop?.zip {
            address2Label.text = "\(city), \(state) \(zip)"
        }else{
            address2View.isHidden = true
        }
        if let country = truckStop?.country {
            address3Label.text = country
        }else{
            address3View.isHidden = true
        }
        if let phone = truckStop?.rawLine3 {
            phoneLabel.text = phone
        }
    }


    
}
