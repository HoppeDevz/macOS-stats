//
//  storage-consumption-view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import Foundation

@MainActor
class StorageConsumptionViewModel: ObservableObject {
    
    @Published var volumes: [IStorageConsumption]
    private let storage_consumption_service: StorageConsumptionService;
        
    private var timer: Timer?;
    
    init(storage_consumption_service: StorageConsumptionService = StorageConsumptionService()) {
        self.storage_consumption_service = storage_consumption_service;
        self.volumes = [];
        self.timer = nil;
        self.start_monitoring();
    }
    

    public func fetch() async {
        
        let volumes = await Task.detached(priority: .background) { [storage_consumption_service] in
            storage_consumption_service.read();
            return storage_consumption_service.get_volumes()
        }.value

        self.volumes = volumes;
        
    }
    
    func start_monitoring() {
        
        Task { [weak self] in
            await self?.fetch()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { [weak self] _ in
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

