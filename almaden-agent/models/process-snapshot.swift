//
//  process-snapshot.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 25/04/25.
//

import Foundation
import SwiftUI

struct IProcessesSnapshotSamples {
    
    var procs: [IProcessSnapshotSample];
    var retrieved_at: DispatchTime;
    
    init() {
        self.procs = [];
        self.retrieved_at = DispatchTime.now();
    }
    
}

struct IProcessSnapshotSample {
    var pid: Int32;
    var appid: String?;
    var name: String;
    // var icon: NSImage;
    var cpu_time: Double;
    var memory_consumption: UInt64;
}


struct IProcessSnapshot {
    
    var pid: Int32;
    var appid: String?;
    var name: String;
    // var icon: NSImage;
    
    var cpu_single_core_percent: Double;
    var cpu_multi_core_percent: Double;
    
    var memory_consumption: UInt64;
    var memory_percent: Double;
    
    var first_sample: IProcessSnapshotSample;
    var second_sample: IProcessSnapshotSample;
    
}
