//
//  ram-memory-consumption.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import Foundation

@MainActor
class RamMemoryConsumptionViewModel: ObservableObject {
    
    @Published var ram_memory_consumption: IRamMemoryConsumption?
    private let ram_memory_consumption_service: RamMemoryConsumptionService;
        
    private var timer: Timer?;
    
    init(ram_memory_consumption_service: RamMemoryConsumptionService = RamMemoryConsumptionService()) {
        self.ram_memory_consumption_service = ram_memory_consumption_service;
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let ram_memory_consumption = await Task.detached(priority: .background) { [ram_memory_consumption_service] in
            return ram_memory_consumption_service.retrieve()
        }.value

        self.ram_memory_consumption = ram_memory_consumption;
        
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

