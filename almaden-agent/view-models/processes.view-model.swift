//
//  processes.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 25/04/25.
//

import Foundation

@MainActor
class ProcessesViewmodel: ObservableObject {
    
    @Published var processes: [IProcessSnapshot] = [];
    private var processes_service: ProcessesService = ProcessesService();
    
    private var timer: Timer?;
    
    init() {
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let processes = await Task.detached(priority: .background) { [processes_service] in
            return processes_service.list_processes()
        }.value

        self.processes = processes;
        
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
