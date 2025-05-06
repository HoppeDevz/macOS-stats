//
//  wifi.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 22/04/25.
//

import Foundation

@MainActor
class WifiViewmodel: ObservableObject {
    
    @Published var nearby_wifi: [IWifi] = [];
    private var wifi_service: WifiService = WifiService();
    
    private var timer: Timer?;
    
    init() {
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let nearby_wifi = await Task.detached(priority: .background) { [wifi_service] in
            return wifi_service.read_nearby_wifi()
        }.value

        self.nearby_wifi = nearby_wifi;
        
    }
    
    func start_monitoring() {
        
        Task { [weak self] in
            await self?.fetch()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
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
