//
//  battery-consumption.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 19/04/25.
//

import Foundation

@MainActor
class BatteryConsumptionViewModel: ObservableObject {

    @Published public var battery_info: IBatteryInfo?;
    private let battery_consumption_service: BatteryConsumptionService;
        
    private var timer: Timer?;
    
    init(battery_consumption_service: BatteryConsumptionService = BatteryConsumptionService()) {
        self.battery_consumption_service = battery_consumption_service;
        self.battery_info = nil;
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let battery_info = await Task.detached(priority: .background) { [battery_consumption_service] in
            return battery_consumption_service.read()
        }.value

        self.battery_info = battery_info;
        
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

