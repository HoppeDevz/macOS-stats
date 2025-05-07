//
//  storage-consumption.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import Foundation
import IOKit.storage

class StorageConsumptionService {
    
    private var volumes:
        [IStorageConsumption] = [];
    
    public func read() {
        
        let keys: [URLResourceKey] = [.volumeNameKey];
        let options: FileManager.VolumeEnumerationOptions = [.skipHiddenVolumes];
        
        guard let paths = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: options) else {
            return;
        };
            
        guard let session = DASessionCreate(kCFAllocatorDefault) else {
            return
        }
        
        for url in paths {
                
            if url.pathComponents.count == 1 || (url.pathComponents.count > 1 && url.pathComponents[1] == "Volumes") {
                    
                if 
                    let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, url as CFURL),
                    let description = DADiskCopyDescription(disk) as? [CFString: Any],
                    let file_system_t = description[kDADiskDescriptionVolumeKindKey] as? String
                {
                    
                    if let disk_name = DADiskGetBSDName(disk) {
                        
                        let BSDName: String = String(cString: disk_name);
                        let free_space: Int64 = self.freeDiskSpaceInBytes(url);
                        let total_space: Int64 = self.totalDiskSpaceInBytes(url);
                        let used_space: Int64 = total_space - free_space;
                        
                        if let index = volumes.firstIndex(where: { $0.BSDName == BSDName }) {
                            
                            volumes[index].free = free_space;
                            volumes[index].used = used_space;
                            volumes[index].size = total_space;
                            volumes[index].file_type = file_system_t;
                            
                        } else {
                            
                            volumes.append(IStorageConsumption(
                                BSDName: BSDName,
                                free: free_space,
                                used: used_space,
                                size: total_space,
                                file_type: file_system_t
                            ));
                            
                        }
                        
                    }
                    
                }
                
            }

        }
        
        
    }
    
    public func get_volumes() -> [IStorageConsumption] {
        
        return self.volumes;
        
    }
    
    private func freeDiskSpaceInBytes(_ path: URL) -> Int64 {
        do {
            if let url = URL(string: path.absoluteString) {
                let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
                if let capacity = values.volumeAvailableCapacityForImportantUsage, capacity != 0 {
                    return capacity
                }
            }
        } catch let err {
            // TODO: Error handling
        }
            
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: path.path)
            if let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            }
        } catch let err {
            // TODO: Error handling
        }
        
        return 0
    }
    
    private func totalDiskSpaceInBytes(_ path: URL) -> Int64 {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: path.path)
            if let totalSpace = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value {
                return totalSpace
            }
        } catch let err {
            // TODO: Error handling
        }
        
        return 0
    }
    
}
