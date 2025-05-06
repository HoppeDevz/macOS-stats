//
//  system-info.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import Foundation

class SystemInfoService {
    
    func fetch_machine_id() -> String? {
        
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        defer { IOObjectRelease(platformExpert) }
        
        if let uuidCF = IORegistryEntryCreateCFProperty(platformExpert, "IOPlatformUUID" as CFString, kCFAllocatorDefault, 0) {
            return (uuidCF.takeUnretainedValue() as? String)
        }
        
        return nil
        
    }
    
    func fetch_os_name() -> String {
        
        return ProcessInfo.processInfo.operatingSystemVersionString;
        
    }
    
    func fetch_os_version() -> String {
        
        let version = ProcessInfo.processInfo.operatingSystemVersion;
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)";
        
    }
    
    func fetch_host_name() -> String {
        
        return Host.current().localizedName ?? "UNKNOWN";
        
    }
    
    func fetch_system_info() -> ISystemInfo {
            
        return ISystemInfo(
            machine_id:     fetch_machine_id() ?? "",
            host_name:      fetch_host_name(),
            os_name:        fetch_os_name(),
            os_version:     fetch_os_version()
        )
        
    }
    
}
