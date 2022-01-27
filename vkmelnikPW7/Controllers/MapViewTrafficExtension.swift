//
//  MapViewTrafficExtension.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 27.01.2022.
//

import YandexMapsMobile

extension MapViewController: YMKTrafficDelegate {
    
    func onTrafficChanged(with trafficLevel: YMKTrafficLevel?) {
        // Nothing.
    }
    
    func onTrafficLoading() {
        
    }
    
    func onTrafficExpired() {
        
    }
    
}
