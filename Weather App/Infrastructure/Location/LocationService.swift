//
//  LocationService.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

struct Coordinate {
    var latitude: Double
    var longitude: Double
}

enum LocationServiceError: Error {
    case LocationServicesOff
    case LocationDisabled
    case NotAuthorized
}

protocol LocationService {
    func startUpdatingLocation()
    var coordinate: PublishSubject<Coordinate> { get }
    var locationServiceError : PublishSubject<LocationServiceError>  { get }
}

final class DefaultLocationService: NSObject {
    private let preferencesService : PreferencesService
    
    let coordinate: PublishSubject<Coordinate> = PublishSubject()
    let locationServiceError : PublishSubject<LocationServiceError> = PublishSubject()
    
    private var locationManager = CLLocationManager()
    
    init(preferencesService: PreferencesService) {
        self.preferencesService = preferencesService
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
}

extension DefaultLocationService: LocationService, CLLocationManagerDelegate {
    
    func startUpdatingLocation() {
        
        self.locationManager.delegate = self
        
        guard CLLocationManager.locationServicesEnabled() else {
            if !self.preferencesService.hasChosen() {
                locationServiceError.onNext(.LocationServicesOff)
            }
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined
            || CLLocationManager.authorizationStatus() == .restricted
            || CLLocationManager.authorizationStatus() == .denied {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func checkLocationAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationServiceError.onNext(.NotAuthorized)
            break
        case .restricted:
            if !self.preferencesService.hasChosen() {
                locationServiceError.onNext(.LocationDisabled)
            }
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            if !self.preferencesService.hasChosen() {
                locationServiceError.onNext(.LocationDisabled)
            }
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last?.coordinate
        self.coordinate.onNext(Coordinate(latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0))
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = nil
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization(status: status)
    }
    
}
