//
//  ViewController.swift
//  vkmelnikPW7
//
//  Created by Vsevolod Melnik on 20.01.2022.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, MapViewControllerProtocol {
    
    private var goButton: UIButton!
    private var clearButton: UIButton!
    private var startLocation: UITextField!
    private var endLocation: UITextField!
    public let locationManager = CLLocationManager()
    
    var coordinates: [CLLocationCoordinate2D] = []
    var annotations = [MKAnnotation]()
    var overlays = [MKOverlay]()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 10
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        return mapView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
        configureUI()
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
        mapView.delegate = self
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
        let markLocationOne = MKPlacemark(coordinate: self.coordinates.first!)
        let markLocationTwo = MKPlacemark(coordinate: self.coordinates.last!)
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: markLocationOne)
        directionRequest.destination = MKMapItem(placemark: markLocationTwo)
        directionRequest.transportType = .automobile
                
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if error != nil {
                print(String(describing: error))
            } else {
                let myRoute: MKRoute? = response?.routes.first
                if let a = myRoute?.polyline {
                    if self.overlays.count > 0 {
                        self.mapView.removeOverlays(self.overlays)
                        self.overlays = []
                    }
                    self.overlays.append(a)
                    self.mapView.addOverlay(a)
                    self.mapView.centerCoordinate = self.coordinates.last!
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9)
                    let region = MKCoordinateRegion(center: self.coordinates.last!, span: span)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
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
}

