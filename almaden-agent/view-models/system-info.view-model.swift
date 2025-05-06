//
//  SystemInfo.ViewModel.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import Foundation


@MainActor
class SystemInfoViewModel: ObservableObject {
    
    @Published var system_info: ISystemInfo?
    private let system_info_service: SystemInfoService;
    
    private var timer: Timer?;
    
    init(system_info_service: SystemInfoService = SystemInfoService()) {
        self.system_info_service = system_info_service;
        self.timer = nil;
        self.start_monitoring();
    }
    
    func fetch() {
        
        self.system_info = 
            system_info_service.fetch_system_info();
        
    }
    
    func start_monitoring() {
        
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
