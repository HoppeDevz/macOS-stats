//
//  File.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 18/04/25.
//

import Foundation
import Cocoa

class CpuConsumptionService {
 
    private var cpu_info: processor_info_array_t!;
    private var num_cpu_info: mach_msg_type_number_t = 0;
    
    private var prev_cpu_info: processor_info_array_t!;
    private var num_prev_cpu_info: mach_msg_type_number_t = 0;
    
    private var usage_per_core: [Double] = [];
    private var usage: Double = 0.0;
    
    private var num_cpusu: natural_t = 0;
    
    private var has_hyperv_cores = false;
    private var num_cpus: uint = 0;
    
    private var timer: DispatchSourceTimer?;
    private let timerQueue = DispatchQueue(label: "almaden-agent.cpu-timer", qos: .background);
    
    init() {
        
        self.setup();
        
    }
    
    public func retrieve() -> ICPUConsumption? {
            
        return ICPUConsumption(
            total: usage
        );
        
    }
    
    private func setup() {
        
        // Fetch if has hyperv cores.
        self.has_hyperv_cores = sysctlByName("hw.physicalcpu") != sysctlByName("hw.logicalcpu");
        
        // Fetch how many CPU's.
        [CTL_HW, HW_NCPU].withUnsafeBufferPointer { mib in
            
            var sizeOfNumCPUs: size_t = MemoryLayout<uint>.size
            let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &self.num_cpus, &sizeOfNumCPUs, nil, 0);
            
            if status != 0 {
                self.num_cpus = 1
            }
        }
        
        self.start_timer();
        
    }
    
    private func start_timer() {
        
        timer = DispatchSource.makeTimerSource(queue: timerQueue);
        timer?.schedule(deadline: .now(), repeating: .seconds(5));
        timer?.setEventHandler { [weak self] in self?.retrieve_cpu_information(); }
        timer?.resume();
        
    }
    
    private func stop_timer() {
        
        timer?.cancel();
        timer = nil;
        
    }
    
    private func retrieve_cpu_information() {
        
        let result: kern_return_t = host_processor_info(
            mach_host_self(), PROCESSOR_CPU_LOAD_INFO,
            &self.num_cpusu, &self.cpu_info, &self.num_cpu_info
        );
        
        if result == KERN_SUCCESS {
                
            self.usage_per_core = [];
            
            for i in 0 ..< Int32(self.num_cpusu) {
                
                if let prev_cpu_info = self.prev_cpu_info {
                            
                    var in_use: Int32;
                    var total: Int32;
                    
                    in_use =
                        (
                            self.cpu_info[Int(CPU_STATE_MAX * i + CPU_STATE_USER)] -
                            prev_cpu_info[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        )
                        +
                        (
                            self.cpu_info[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)] -
                            prev_cpu_info[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        )
                        +
                        (
                            self.cpu_info[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)] -
                            prev_cpu_info[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                        );
                    
                    total = in_use +
                        (
                            self.cpu_info[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)] -
                            prev_cpu_info[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                        );
                    
                    usage_per_core.append(Double(in_use) / Double(total));
                    
                }
                
            }
            
            if self.usage_per_core.count > 0 {
                
                let total = Double(self.usage_per_core.reduce(0, +));
                let count = Double(self.usage_per_core.count);
                
                self.usage =  total / count;
                
            }
            
            if let prev = self.prev_cpu_info {
                
                let prev_size = Int(self.num_prev_cpu_info) * MemoryLayout<integer_t>.stride;
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prev), vm_size_t(prev_size));
                
            }
            
            self.prev_cpu_info = self.cpu_info;
            self.num_prev_cpu_info = self.num_cpu_info;
                        
            self.cpu_info = nil;
            self.num_cpu_info = 0;
            
        }
        
    }
    
}
