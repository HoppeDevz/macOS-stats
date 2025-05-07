//
//  cpu-consumption.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 18/04/25.
//

import Foundation

@MainActor
class CpuConsumptionViewModel: ObservableObject {

    @Published public var cpu_consumption: ICPUConsumption?;
    private let cpu_consumption_service: CpuConsumptionService;
        
    private var timer: Timer?;
    
    init(cpu_consumption_service: CpuConsumptionService = CpuConsumptionService()) {
        self.cpu_consumption_service = cpu_consumption_service;
        self.cpu_consumption = nil;
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let cpu_consumption = await Task.detached(priority: .background) { [cpu_consumption_service] in
            return cpu_consumption_service.retrieve()
        }.value

        self.cpu_consumption = cpu_consumption;
        
    }
    
    func start_monitoring() {
        
        Task { [weak self] in
            await self?.fetch()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
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

