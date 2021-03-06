//
//  ViewController.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 20.01.2022.
//

import Foundation
import UIKit
import YandexMapsMobile

class MapViewController: UIViewController, MapViewControllerProtocol {
    
    private var compass: Compass!
    private var goButton: UIButton!
    private var eatButton: UIButton!
    private var plusButton: UIButton!
    private var minusButton: UIButton!
    private var distanceLabel: UILabel!
    private var clearButton: UIButton!
    private var startLocation: UITextField!
    private var endLocation: UITextField!
    
    var drivingSession: YMKDrivingSession?
    var trafficLayer : YMKTrafficLayer!
    var searchManager: YMKSearchManager?
    var searchSession: YMKSearchSession?
    
    var mainRoute = Route()
    
    
    private let mapView: YMKMapView = {
        let mapView = YMKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 10
        mapView.translatesAutoresizingMaskIntoConstraints = false
        // TODO: add other settings.
        return mapView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        initTraffic()
        searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    }
    
    private func initTraffic() {
        trafficLayer = YMKMapKit.sharedInstance().createTrafficLayer(with: mapView.mapWindow)
        //trafficLayer.addTrafficListener(withTrafficListener: self)
        trafficLayer.setTrafficVisibleWithOn(true)
    }

    private func configureUI() {
        view.backgroundColor = .black
        configureMapView()
        configureButtons()
        configureTextFields()
        configureDistanceLabel()
        configureCompass()
        configurePlusMinus()
        configureEatButton()
    }
    
    private func configureCompass() {
        let compass = Compass()
        view.addSubview(compass)
        compass.pinRight(to: view, 10)
        compass.pinBottom(to: goButton.topAnchor, 10)
        self.compass = compass
    }
    
    private func configureEatButton() {
        let button = MapActionButton(backgroundColor: UIColor(white: 0.7, alpha: 0.97), text: "Eat")
        view.addSubview(button)
        button.pinRight(to: view, 10)
        button.pinBottom(to: plusButton.topAnchor, 10)
        button.addTarget(self, action: #selector(eatButtonWasPressed), for: .touchUpInside)
        
        self.eatButton = button
    }
    
    private func configurePlusMinus() {
        let plus = MapActionButton(backgroundColor: UIColor(white: 0.7, alpha: 0.97), text: "+")
        let minus = MapActionButton(backgroundColor: UIColor(white: 0.7, alpha: 0.97), text: "-")
        view.addSubview(minus)
        minus.pinRight(to: view, 10)
        minus.pinBottom(to: compass.topAnchor, 10)
        minus.addTarget(self, action: #selector(minusButtonWasPressed), for: .touchUpInside)
        view.addSubview(plus)
        plus.pinRight(to: view, 10)
        plus.pinBottom(to: minus.topAnchor, 10)
        plus.addTarget(self, action: #selector(plusButtonWasPressed), for: .touchUpInside)
        
        self.plusButton = plus
        self.minusButton = minus
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.pin(to: view)
    }
    
    private func configureButtons() {
        let goButton = MapActionButton(backgroundColor: UIColor(red: 1.0, green: 0.8, blue: 0.1, alpha: 0.97), text: "Go")
        let clearButton = MapActionButton(backgroundColor: UIColor(white: 0.7, alpha: 0.97), text: "Clear")
        clearButton.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchUpInside)
        goButton.addTarget(self, action: #selector(goButtonWasPressed), for: .touchUpInside)
        goButton.isEnabled = false
        clearButton.isEnabled = false
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        view.addSubview(buttonStack)
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.pin(to: view, [.bottom: 10, .left: 10, .right: 10])
        [goButton, clearButton].forEach { button in
            button.setHeight(to: 40)
            buttonStack.addArrangedSubview(button)
        }
        self.goButton = goButton
        self.clearButton = clearButton
    }
    
    private func configureTextFields() {
        let startLocation = MapTextField(backgroundColor: UIColor(white: 0.7, alpha: 0.97), placeholder: "Start location")
        let endLocation = MapTextField(backgroundColor: UIColor(white: 0.7, alpha: 0.97), placeholder: "End location")
        let textStack = UIStackView()
        textStack.axis = .vertical
        view.addSubview(textStack)
        textStack.spacing = 10
        textStack.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 10)
        textStack.pin(to: view, [.left: 10, .right: 10])
        [startLocation, endLocation].forEach { textField in
            textField.setHeight(to: 40)
            textStack.addArrangedSubview(textField)
        }
        
        startLocation.delegate = self
        endLocation.delegate = self
        self.startLocation = startLocation
        self.endLocation = endLocation
    }
    
    private func configureDistanceLabel() {
        let distanceLabel = UILabel()
        distanceLabel.text = ""
        distanceLabel.backgroundColor = UIColor(white: 0.7, alpha: 0.97)
        distanceLabel.layer.cornerRadius = 5
        distanceLabel.layer.masksToBounds = true
        view.addSubview(distanceLabel)
        distanceLabel.pinLeft(to: view, 10)
        distanceLabel.pinTop(to: endLocation.bottomAnchor, 10)
        
        self.distanceLabel = distanceLabel
    }
    
    
}

// Map logic.
extension MapViewController {
    
    // Find food in the camera's field of view.
    @objc func eatButtonWasPressed() {
        let responseHandler = {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
            if let response = searchResponse {
                self.onSearchResponse(response, mapView: self.mapView)
            } else {
                self.onSearchError(error!)
            }
        }
        
        searchSession = searchManager!.submit(
            withText: "cafe restaurant bar",
            geometry: YMKVisibleRegionUtils.toPolygon(with: self.mapView.mapWindow.map.visibleRegion),
            searchOptions: YMKSearchOptions(),
            responseHandler: responseHandler)
    }
    
    @objc func plusButtonWasPressed() {
        let zoom = mapView.mapWindow.map.cameraPosition.zoom + 1
        let target = mapView.mapWindow.map.cameraPosition.target
        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: target, zoom: zoom, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1),
            cameraCallback: nil)
    }
    
    @objc func minusButtonWasPressed() {
        let zoom = mapView.mapWindow.map.cameraPosition.zoom - 1
        let target = mapView.mapWindow.map.cameraPosition.target
        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: target, zoom: zoom, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1),
            cameraCallback: nil)
    }
    
    @objc func clearButtonWasPressed() {
        startLocation.text = ""
        endLocation.text = ""
        goButton.isEnabled = false
        clearButton.isEnabled = false
    }
    
    func addPointInRoute(address: String, completion: @escaping () -> Void) {
        let responseHandler = {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
            if let response = searchResponse {
                self.onRoutePointSearchResponse(response, completion: completion)
            } else {
                self.onSearchError(error!)
            }
        }
        
        searchSession = searchManager!.submit(
            withText: address,
            geometry: YMKVisibleRegionUtils.toPolygon(with: self.mapView.mapWindow.map.visibleRegion),
            searchOptions: YMKSearchOptions(),
            responseHandler: responseHandler)
    }
    
    @objc func goButtonWasPressed() {
        guard
            let first = startLocation.text,
            let second = endLocation.text,
            first != second
        else {
            return
        }
        mainRoute.clear()
        addPointInRoute(address: first, completion: { [self]() in
                            self.addPointInRoute(address: second, completion: {() in
                                self.buildPath()
                            })})
    }
    
    private func buildPath() {
        if self.mainRoute.coordinates.count < 2 {
            return
        }
        let requestPoints : [YMKRequestPoint] = [
            YMKRequestPoint(point: mainRoute.coordinates.first!,
                                   type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: mainRoute.coordinates.last!,
                                   type: .waypoint, pointContext: nil)
        ]
        
        let responseHandler = {(routesResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
            if let routes = routesResponse {
                self.onRoutesReceived(routes)
            } else {
                self.onRoutesError(error!)
            }
        }
        
        let drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()
        drivingSession = drivingRouter.requestRoutes(
            with: requestPoints,
            drivingOptions: YMKDrivingDrivingOptions(),
            vehicleOptions: YMKDrivingVehicleOptions(),
            routeHandler: responseHandler)
        
        // Move camera.
        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: requestPoints.first!.point, zoom: 15, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 2),
            cameraCallback: nil)
    }
    
    /*
     Check text fields.
     */
    public func canGo() -> Bool {
        return startLocation.text != ""
            && endLocation.text != "";
    }
    
    /*
     Go, if adress in end text field is finished.
     */
    public func tryGo(_ textField: UITextField) {
        if (canGo() && textField == endLocation) {
            goButtonWasPressed();
        }
    }
    
    public func enableButtons() {
        goButton.isEnabled = true
        clearButton.isEnabled = true
    }
    
    public func disableButtons() {
        goButton.isEnabled = false
        clearButton.isEnabled = false
    }
    
    public func updateCompass(heading: Double) {
        compass.update(heading: heading)
    }
    
    func onRoutePointSearchResponse(_ response: YMKSearchResponse, completion: @escaping () -> Void) {
        if let point = response.collection.children.first?.obj?.geometry.first?.point {
            mainRoute.addCoords(point)
            completion()
        }
    }
    
    // Code from Yandex Mapkit Demo.
    
    private func onRoutesReceived(_ routes: [YMKDrivingRoute]) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        mapObjects.clear()
        if let route = routes.first {
            let line = mapObjects.addColoredPolyline()
            YMKRouteHelper.updatePolyline(withPolyline: line, route: route, style: YMKRouteHelper.createDefaultJamStyle())
            distanceLabel.text = " "
                + String(format: "%.0f", route.metadata.weight.distance.value)
                + " meters "
        }
    }
    
    func onRoutesError(_ error: Error) {
        let routingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
        var errorMessage = "Unknown error"
        if routingError.isKind(of: YRTNetworkError.self) {
            errorMessage = "Network error"
        } else if routingError.isKind(of: YRTRemoteError.self) {
            errorMessage = "Remote server error"
        }
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
