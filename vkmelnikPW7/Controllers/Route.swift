//
//  RouteManager.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 28.01.2022.
//

import CoreLocation

struct Route {
    var coordinates: [CLLocationCoordinate2D] = []
}

extension Route {
    mutating func clear() {
        coordinates = []
    }
    
    mutating func addCoords(_ coords: CLLocationCoordinate2D) {
        coordinates.append(coords)
    }
}
