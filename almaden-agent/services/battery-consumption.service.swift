//
//  battery-consumption.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 19/04/25.
//

import Foundation

import IOKit
import IOKit.ps

class BatteryConsumptionService {
 
    private var service: io_connect_t =
        IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleSmartBattery"));
    
    public func read() -> IBatteryInfo? {
        
        let psInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let psList = IOPSCopyPowerSourcesList(psInfo).takeRetainedValue() as [CFTypeRef]
        
        for ps in psList {
            
            if let list = IOPSGetPowerSourceDescription(psInfo, ps).takeUnretainedValue() as? [String: Any] {
                
                let powerSource = list[kIOPSPowerSourceStateKey] as? String ?? "AC Power";
                let level = Double(list[kIOPSCurrentCapacityKey] as? Int ?? 0) / 100;
                let cycles = self.getIntValue("CycleCount" as CFString) ?? 0;
                let isARM = Arch.isARM();
                
                let currentCapacity = self.getIntValue("AppleRawCurrentCapacity" as CFString) ?? 0;
                let designedCapacity = self.getIntValue("DesignCapacity" as CFString) ?? 1;
                let maxCapacity = self.getIntValue((isARM ? "AppleRawMaxCapacity" : "MaxCapacity") as CFString) ?? 1;
                let health = Int((Double(100 * maxCapacity) / Double(designedCapacity)).rounded(.toNearestOrEven));
                
                return IBatteryInfo(
                    level: level,
                    cycles: cycles,
                    health: health
                );
                
            }
        }
        
        return nil;
        
    }
    
    private func getBoolValue(_ forIdentifier: CFString) -> Bool? {
        if let value = IORegistryEntryCreateCFProperty(self.service, forIdentifier, kCFAllocatorDefault, 0) {
            return value.takeRetainedValue() as? Bool
        }
        return nil
    }
        
    private func getIntValue(_ identifier: CFString) -> Int? {
        if let value = IORegistryEntryCreateCFProperty(self.service, identifier, kCFAllocatorDefault, 0) {
            return value.takeRetainedValue() as? Int
        }
        return nil
    }
        
    private func getDoubleValue(_ identifier: CFString) -> Double? {
        if let value = IORegistryEntryCreateCFProperty(self.service, identifier, kCFAllocatorDefault, 0) {
            return value.takeRetainedValue() as? Double
        }
        return nil
    }
    
    deinit {
        IOObjectRelease(self.service)
    }
    
}
