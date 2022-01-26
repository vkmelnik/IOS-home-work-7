//
//  MapViewExtension.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 20.01.2022.
//

import MapKit
import UIKit

extension MapViewController: UITextFieldDelegate {
    // Hide keyboard when enter is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.tryGo(textField);
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (self.canGo()) {
            self.enableButtons();
        } else {
            self.disableButtons();
        }
    }
    
    // Hide keyboard when touched outside textfields.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !(touches.first?.view is UITextField) {
            view.endEditing(true)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    // Draw route.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5
        return renderer
    }
}
