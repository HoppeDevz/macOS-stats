//
//  applications.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 29/04/25.
//

import Foundation
import AppKit

class ApplicationsService {
    
    let fs =
        FileManager();
        
    public func applications_snapshot() -> [IApplicationSnapshot] {
        
        var snapshot: [IApplicationSnapshot] = [];
        
        for directory in applications_directories() {
            
            let enumerator =
                fs.enumerator(at: directory.url, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants);
            
            while let file = (enumerator?.nextObject() as? URL) {
                
                guard file.pathExtension == "app" else { continue }
                guard let psinfo_url = BundleHandler.try_get_bundle_psinfo_path(file) else { continue };
                
                snapshot.append(IApplicationSnapshot(
                    name: file.deletingPathExtension().lastPathComponent,
                    scope: directory.scope,
                    bundle_path: file.path,
                    ps_info_path: psinfo_url.path
                ));

            }
            
        }
        
        return snapshot;
        
    }
    
    public func applications_directories() -> [IApplicationsDirectory] {
        
        var directories: [IApplicationsDirectory] = [];
        
        let user = fs.urls(for: .applicationDirectory, in: .userDomainMask).first;
        let shared = fs.urls(for: .applicationDirectory, in: .localDomainMask).first;
        let system = fs.urls(for: .applicationDirectory, in: .systemDomainMask).first;
        
        if let user_dir = user {
            directories.append(IApplicationsDirectory(url: user_dir, scope: EApplicationScope.USER));
        }
        if let shared_dir = shared {
            directories.append(IApplicationsDirectory(url: shared_dir, scope: EApplicationScope.SHARED));
        }
        if let system_dir = system {
            directories.append(IApplicationsDirectory(url: system_dir, scope: EApplicationScope.SYSTEM));
        }
        
        return directories;
        
    }
    
    public func installed_apps() -> [IApplication] {
        
        let snapshots = applications_snapshot();
        var applications: [IApplication] = [];
        
        for snapshot in snapshots {
            
            applications.append(IApplication(
                name: snapshot.name,
                scope: snapshot.scope,
                bundle_path: snapshot.bundle_path,
                details: BundleHandler.try_get_bundle_details(snapshot.ps_info_path)
            ));
            
        }
        
        return applications;
        
    }
    
}
