//
//  LocationService.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 3/27/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import MapKit

//public protocol LocationServiceDelegate: NSObjectProtocol {
//    func didUpdate(_ location: CLLocation);
//}

public protocol LocationServicing {
    static var shared: LocationServicing {get}
    var locationManager: CLLocationManager {get}
//    var delegate: LocationServiceDelegate? {get}
    
    func currentLocation() -> CLLocation?
    func startTracking()
    func stopTracking()
    func requestAuthorization(completion: ((Bool) -> Void)?)
}

let locationUpdatedNotification = Notification.Name("locationUpdatedNotificaiton")

class LocationService: NSObject, LocationServicing {
    static var shared: LocationServicing = LocationService()
    internal let locationManager = CLLocationManager()
    private var dataStorageManager: DataStorageManager
//    var delegate: LocationServiceDelegate?
    private var authorizationCompletion: ((Bool) -> Void)?
    func currentLocation() -> CLLocation? {
        return self.locationManager.location
    }
    
    public init(with dataStorageManager: DataStorageManager) {
        self.dataStorageManager = dataStorageManager
        super.init()
    }
    
    override public convenience init() {
        self.init(with: DataStorageManager.sharedInstance)
    }
    
    func startTracking() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func stopTracking() {
        self.locationManager.stopUpdatingLocation()
    }
    
    public func requestAuthorization(completion: ((Bool) -> Void)?) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            authorizationCompletion = completion
            locationManager.requestWhenInUseAuthorization()
        } else {
            completion?(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways)
        }
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        dataStorageManager.saveLocations(locations) {
            //
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationCompletion?(status == .authorizedWhenInUse || status == .authorizedAlways)
        authorizationCompletion = nil
        
    }
}
