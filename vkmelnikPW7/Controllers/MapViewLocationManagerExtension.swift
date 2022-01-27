//
//  MapViewLocationManagerExtension.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 27.01.2022.
//

import UIKit
import CoreLocation

extension MapViewController: CLLocationManagerDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        updateCompass(heading: (Double(newHeading.magneticHeading)))
    }
    
}
