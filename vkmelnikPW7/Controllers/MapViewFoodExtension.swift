//
//  MapViewFoodExtension.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 28.01.2022.
//

import YandexMapsMobile

// Search food in the camera's field of view.
extension MapViewController {
    func onSearchResponse(_ response: YMKSearchResponse, mapView: YMKMapView) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        mapObjects.clear()
        for searchResult in response.collection.children {
            if let point = searchResult.obj?.geometry.first?.point {
                let placemark = mapObjects.addPlacemark(with: point)
                placemark.setIconWith(UIImage(named: "SearchResult")!)
            }
        }
    }
    
    func onSearchError(_ error: Error) {
        let searchError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
        var errorMessage = "Unknown error"
        if searchError.isKind(of: YRTNetworkError.self) {
            errorMessage = "Network error"
        } else if searchError.isKind(of: YRTRemoteError.self) {
            errorMessage = "Remote server error"
        }
            
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
        present(alert, animated: true, completion: nil)
    }
}
