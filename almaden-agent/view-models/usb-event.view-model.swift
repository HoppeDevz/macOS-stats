//
//  usb.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 05/05/25.
//

import Foundation

@MainActor
class USBViewmodel: ObservableObject {
    
    @Published var events: [IUSBEvent] = [];
    
    private var timer: Timer?;
    
    init() {
        self.timer = nil;
        self.start_monitoring();
        USBService.watch_usb_ports();
    }
    
    public func fetch() async {
        
        let events = await Task.detached(priority: .background) { [] in
            return USBService.retrieve_events();
        }.value

        self.events = events;
        
    }
    
    func start_monitoring() {
        
        Task { [weak self] in
            await self?.fetch()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
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
