//
//  geolocation.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 28/04/25.
//

import Foundation

@MainActor
class GeolocationViewmodel: ObservableObject {
    
    @Published var geolocation: IGeolocation? = nil;
    private var geolocation_service: GeolocationService = GeolocationService();
    
    private var timer: Timer?;
    
    init() {
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let geolocation = await Task.detached(priority: .background) { [geolocation_service] in
            return geolocation_service.get_geolocation()
        }.value

        self.geolocation = geolocation;
        
    }
    
    func start_monitoring() {
        
        Task { [weak self] in
            await self?.fetch()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 180.0, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.fetch()
            }
        }
        
    }
    
    func stop_monitoring() {
        
        self.timer?.invalidate();
        self.timer = nil;
        
    }
    
}
