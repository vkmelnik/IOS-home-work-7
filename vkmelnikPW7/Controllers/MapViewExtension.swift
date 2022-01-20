//
//  MapViewExtension.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 20.01.2022.
//

import UIKit

extension MapViewController: UITextFieldDelegate {
    // Hide keyboard when enter is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Hide keyboard when touched outside textfields.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !(touches.first?.view is UITextField) {
            view.endEditing(true)
        }
    }
}
