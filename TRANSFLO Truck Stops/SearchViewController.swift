//
//  SearchViewController.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 5/7/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!

    public var address: String {
        get {
            let name = makeAddressComponent(nameTextField)
            let address = makeAddressComponent(addressTextField)
            let city = makeAddressComponent(cityTextField)
            let state = makeAddressComponent(stateTextField)
            let zip = makeAddressComponent(zipTextField)
            
            let tempAddress = name + address + city + state + zip
            return tempAddress
        }
    }
    
    func makeAddressComponent(_ textField: UITextField) -> String {
        if var text = textField.text {
            text.append(",")
            return text
        }
        return ""
    }

}
