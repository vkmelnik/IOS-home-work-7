//
//  ViewController.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 20.01.2022.
//

import UIKit
import CoreLocation
import YandexMapsMobile

class MapViewController: UIViewController, MapViewControllerProtocol {
    
    
    private var goButton: UIButton!
    private var clearButton: UIButton!
    private var startLocation: UITextField!
    private var endLocation: UITextField!
    public let locationManager = CLLocationManager()
    
    var coordinates: [CLLocationCoordinate2D] = []
    var drivingSession: YMKDrivingSession?
    var trafficLayer : YMKTrafficLayer!
    
    
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
        locationManager.requestWhenInUseAuthorization()
        configureUI()
        initTraffic()
    }
    
    private func initTraffic() {
        trafficLayer = YMKMapKit.sharedInstance().createTrafficLayer(with: mapView.mapWindow)
        trafficLayer.addTrafficListener(withTrafficListener: self)
        trafficLayer.setTrafficVisibleWithOn(true)
    }

    private func configureUI() {
        view.backgroundColor = .black
        configureMapView()
        configureButtons()
        configureTextFields()
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.pin(to: view)
    }
    
    private func configureButtons() {
        let goButton = MapActionButton(backgroundColor: .blue, text: "Go")
        let clearButton = MapActionButton(backgroundColor: .lightGray, text: "Clear")
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
        let startLocation = MapTextField(backgroundColor: .lightGray, placeholder: "Start location")
        let endLocation = MapTextField(backgroundColor: .lightGray, placeholder: "End location")
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
    
    @objc func clearButtonWasPressed() {
        startLocation.text = ""
        endLocation.text = ""
        goButton.isEnabled = false
        clearButton.isEnabled = false
    }
    
    @objc func goButtonWasPressed() {
        guard
            let first = startLocation.text,
            let second = endLocation.text,
            first != second
        else {
            return
        }
        self.coordinates = []
        let group = DispatchGroup()
        group.enter()
        getCoordinateFrom(address: first, completion: {
            [weak self] coords,_ in
                if let coords = coords {
                    self?.coordinates.append(coords)
                }
            group.leave()
        })
        group.enter()
        getCoordinateFrom(address: second, completion: {
            [weak self] coords,_ in
                if let coords = coords {
                    self?.coordinates.append(coords)
                }
            group.leave()
        })
        
        group.notify(queue: .main) {
            DispatchQueue.main.async { [weak self] in
                self?.buildPath()
            }
        }
    }
    
    private func buildPath() {
        if self.coordinates.count < 2 {
            return
        }
        let requestPoints : [YMKRequestPoint] = [
            YMKRequestPoint(point: YMKPoint(latitude: coordinates.first!.latitude,
                                            longitude: coordinates.first!.longitude),
                                                type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: YMKPoint(latitude: coordinates.last!.latitude,
                                            longitude: coordinates.last!.longitude),
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
        
        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: requestPoints.first!.point, zoom: 15, azimuth: 0, tilt: 0),
                animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 5),
                cameraCallback: nil)
    }
    
    public func canGo() -> Bool {
        return startLocation.text != ""
            && endLocation.text != "";
    }
    
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
    
    private func getCoordinateFrom(address: String,
                                   completion:
                                    @escaping(_ coordinate: CLLocationCoordinate2D?,
                                              _ error: Error?) -> () ) {
        DispatchQueue.global(qos: .background).async {
            CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1)
            }
        }
    }
    
    // Code from Yandex Mapkit Demo.
    
    private func onRoutesReceived(_ routes: [YMKDrivingRoute]) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        mapObjects.clear()
        for route in routes {
            mapObjects.addPolyline(with: route.geometry)
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
