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
        print("Go")
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
}

