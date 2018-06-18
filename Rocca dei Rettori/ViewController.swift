//
//  ViewController.swift
//  Rocca dei Rettori
//
//  Created by Denis Bystruev on 18/06/2018.
//  Copyright © 2018 Denis Bystruev. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    /// Rocca dei Rettori's coordinate
    let center = CLLocationCoordinate2D(latitude: 41.129437, longitude: 14.782375)
    
    /// Point to save our pin
    var pin: MKPointAnnotation!
    
    /// Tap gesture recognizer for the map view
    var tapGesture: UITapGestureRecognizer!
    
    /// Double gesture recognizer for the map view
    var doubleTapGesture: UITapGestureRecognizer!
    
    /// Long press gesture recognizer for the map viewe
    var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup map view
        setupMapView(center: center)
        
        // add gesture recognizers
        addGestureRecognizers()
    }
    
    
    /// Setup map view in the main view
    func setupMapView(center: CLLocationCoordinate2D) {
        // allow user to zoom
        mapView.isZoomEnabled = true
        
        // allow user to scroll
        mapView.isScrollEnabled = true
        
        // setup hybrid map type
        mapView.mapType = .standard
        //mapView.mapType = .satellite
        
        // set the span area
        let span = MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
        
        // set the region
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        
        // add pin at the center
        setPin(center)
    }
    
    
    /// Add tap gesture recognizers
    func addGestureRecognizers() {
        // add single tap gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
        
        // add double tap gesture recognizer
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTapGesture)
        
        // add long press handler
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(_:)))
        longPressGesture.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    
    /// Handle tap gesture
    ///
    /// - Parameter gestureRecognizer: UITapGestureRecognizer passed to us by Cocoa Touch
    @objc func tapHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        // recognize one tap, ignore double taps
        if gestureRecognizer.state == .ended && gestureRecognizer.numberOfTapsRequired == 1 {
            // for one tap we change map type
            switch mapView.mapType {
            case .hybrid:
                mapView.mapType = .hybridFlyover
                label.text = "Hybrid Flyover"
            case .hybridFlyover:
                mapView.mapType = .mutedStandard
                label.text = "Muted Standard"
            case .mutedStandard:
                mapView.mapType = .satellite
                label.text = "Satellite"
            case .satellite:
                mapView.mapType = .satelliteFlyover
                label.text = "Satellite Flyover"
            case .satelliteFlyover:
                mapView.mapType = .standard
                label.text = "Standard"
            case .standard:
                mapView.mapType = .hybrid
                label.text = "Hybrid"
            }
        }
    }
    
    
    /// Handle long press gesture
    ///
    /// - Parameter gestureRecognizer: UILongPressGestureRecognizer passed to us by Cocoa Touch
    @objc func longPressHandler(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // get the location of tap on screen
        let location = gestureRecognizer.location(in: self.mapView)
        
        // get the coordinate corresponding to tap location
        let coordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        // display latitude and longitude in the label
        self.label.text = "\(Float(coordinate.latitude)) : \(Float(coordinate.longitude))"
        
        // pin the map
        self.setPin(coordinate)
    }
    
    
    // Don't recognize a single tap until a double tap fails
    // see https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/coordinating_multiple_gesture_recognizers/preferring_one_gesture_over_another
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == doubleTapGesture && otherGestureRecognizer == tapGesture
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == tapGesture && otherGestureRecognizer == doubleTapGesture
    }
    
    
    /// Creates a pin on the map at coordinate
    ///
    /// - Parameter coordinate: place where to put pin on
    func setPin(_ coordinate: CLLocationCoordinate2D) {
        // remove previous annotation
        if let pin = pin {
            mapView.removeAnnotation(pin)
        }
        
        // create a point annotation
        pin = MKPointAnnotation()
        
        // set annotation's coordinate
        pin.coordinate = coordinate
        
        // add annotation to map
        mapView.addAnnotation(pin)
    }
}
