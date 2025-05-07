//
//  usb-devices.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 06/05/25.
//

import Foundation

@MainActor
class USBDevicesViewmodel: ObservableObject {
    
    @Published var connected_devices: [IUSBDevice] = [];
    let connected_devices_services: USBDevicesService = USBDevicesService();
    
    private var timer: Timer?;
    
    init() {
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let connected_devices = await Task.detached(priority: .background) { [connected_devices_services] in
            return connected_devices_services.retrieve_connected_devices();
        }.value

        self.connected_devices = connected_devices;
        
    }
    
    func start_monitoring() {
        
        Task { [weak self] in
            await self?.fetch()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
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
