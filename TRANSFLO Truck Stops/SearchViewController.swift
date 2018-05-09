//
//  SearchViewController.swift
//  TRANSFLO Truck Stops
//
//  Created by Kristopher Sandrick on 5/7/18.
//  Copyright © 2018 Kristopher Sandrick. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.becomeFirstResponder()
        }
    }
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "unwindToMain", sender: self)
        return true
    }
    
    public var searchPredicate: NSPredicate? {
        var predicateArray = [NSPredicate]()
        if let name = nameTextField.text, !name.isEmpty {
            let namePredicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
            predicateArray.append(namePredicate)
        }
        if let city = cityTextField.text, !city.isEmpty {
            let cityPredicate = NSPredicate(format: "city MATCHES[cd] %@", city)
            predicateArray.append(cityPredicate)
        }
        if let state = stateTextField.text, !state.isEmpty {
            let statePredicate = NSPredicate(format: "state MATCHES[cd] %@", state)
            predicateArray.append(statePredicate)
        }
        if let zip = zipTextField.text, !zip.isEmpty {
            let zipPredicate = NSPredicate(format: "zip = %@", zip)
            predicateArray.append(zipPredicate)
        }
        return NSCompoundPredicate(type: .and, subpredicates: predicateArray)
    }

}
