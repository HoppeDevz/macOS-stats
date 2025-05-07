//
//  applications.view-model.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 29/04/25.
//

import Foundation

@MainActor
class ApplicationsViewmodel: ObservableObject {
    
    @Published var applications: [IApplication] = [];
    private var applications_service: ApplicationsService = ApplicationsService();
    
    private var timer: Timer?;
    
    init() {
        self.timer = nil;
        self.start_monitoring();
    }
    
    public func fetch() async {
        
        let applications = await Task.detached(priority: .background) { [applications_service] in
            return applications_service.installed_apps()
        }.value

        self.applications = applications;
        
    }
    
    func start_monitoring() {
        
        Task { [weak self] in
            await self?.fetch()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 180.0, repeats: true) { [weak self] _ in
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
