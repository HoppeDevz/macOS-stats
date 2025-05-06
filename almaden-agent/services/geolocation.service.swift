//
//  geolocation.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 28/04/25.
//

import Foundation
import CoreLocation

class GeolocationService {
    
    let locationManager =
        CLLocationManager()
    
    init() {
        locationManager.requestWhenInUseAuthorization();
    }
 
    public func get_geolocation() -> IGeolocation {
        
        return IGeolocation(
            lat: locationManager.location?.coordinate.latitude ?? 0,
            long: locationManager.location?.coordinate.longitude ?? 0
        )
        
    }
    
}
