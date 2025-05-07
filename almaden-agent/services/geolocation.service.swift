//
//  geolocation.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 28/04/25.
//

import Foundation
import CoreLocation

class GeolocationService: NSObject, CLLocationManagerDelegate {
    
    private let locationManager =
        CLLocationManager();
    
    override init() {
        super.init();
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
    }
 
    public func get_geolocation() -> IGeolocation {
        
        return IGeolocation(
            lat: locationManager.location?.coordinate.latitude ?? 0,
            long: locationManager.location?.coordinate.longitude ?? 0
        )
        
    }
    
    deinit {
        locationManager.delegate = nil;
    }
    
}
