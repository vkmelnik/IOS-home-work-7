//
//  RouteManager.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 28.01.2022.
//

import YandexMapsMobile

struct Route {
    var coordinates: [YMKPoint] = []
}

extension Route {
    mutating func clear() {
        coordinates = []
    }
    
    mutating func addCoords(_ coords: YMKPoint) {
        coordinates.append(coords)
    }
}
