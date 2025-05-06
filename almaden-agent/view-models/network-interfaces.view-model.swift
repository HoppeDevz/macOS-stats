//
//  network-interfaces.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 24/04/25.
//

import Foundation

@MainActor
class NetworkInterfacesViewmodel: ObservableObject {
    
    @Published var interfaces: [INetworkInterface] = [];
    private var interfaces_service: NetworkInterfacesService = NetworkInterfacesService();
    
    private var timer: Timer?;
    
    init() {
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let interfaces = await Task.detached(priority: .background) { [interfaces_service] in
            return interfaces_service.read()
        }.value

        self.interfaces = interfaces;
        
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
