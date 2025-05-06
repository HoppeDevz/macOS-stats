//
//  ram-memory-consumption.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import Foundation

class RamMemoryConsumptionService {
    
    private var total: Double = 0;
    private var used: Double = 0;
    private var free: Double = 0;
    
    private var swapins: Int64 = 0;
    private var swapouts: Int64 = 0;
    
    private var vm_total: UInt64 = 0;
    private var vm_used: UInt64 = 0;
    private var vm_free: UInt64 = 0;
    
    
    init() {
        self.setup();
    }
    
    public func retrieve() -> IRamMemoryConsumption {
        
        return IRamMemoryConsumption(
            total: self.total,
            used: self.used,
            free: self.free,
            
            swap_in: self.swapins,
            swap_out: self.swapouts,
            
            vm_total: self.vm_total,
            vm_used: self.vm_used,
            vm_free: self.vm_free
        );
        
    }
        
    public func setup() {
        
        var stats = host_basic_info();
        var count = UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size);
        
        let pstats = withUnsafeMutablePointer(to: &stats) { UnsafeMutableRawPointer($0) }
        let pint = pstats.bindMemory(to: integer_t.self, capacity: Int(count));
        
        let kerr: kern_return_t = host_info(mach_host_self(), HOST_BASIC_INFO, pint, &count);
        
        if kerr == KERN_SUCCESS {
            
            self.total = Double(stats.max_mem);
            
            DispatchQueue.global(qos: .background).async {
                self.read_thread();
            }
            
            return
        }
        
        self.total = 0;
            
    }
    
    private func read_thread() {
        
        while (true) {
            self.retrieve_ram_info();
            self.retrieve_vm_info();
            Thread.sleep(forTimeInterval: 1.0);
        }
        
    }
    
    private func retrieve_vm_info() {
        
        var susage = ISwapUsage(xsu_total: 0, xsu_available: 0, xsu_used: 0, xsu_pagesize: 0, encrypted: false);
        var size = MemoryLayout<ISwapUsage>.stride;
        let result = sysctlbyname("vm.swapusage", &susage, &size, nil, 0);
        
        if result == KERN_SUCCESS {
            
            self.vm_total = susage.xsu_total;
            self.vm_used = susage.xsu_used;
            self.vm_free = susage.xsu_available;
            
        }
        
    }
    
    private func retrieve_ram_info() {
        
        var stats = vm_statistics64();
        var count = UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size);
        
        let result: kern_return_t = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            
            let active = Double(stats.active_count) * Double(vm_page_size);
            let speculative = Double(stats.speculative_count) * Double(vm_page_size);
            let inactive = Double(stats.inactive_count) * Double(vm_page_size);
            let wired = Double(stats.wire_count) * Double(vm_page_size);
            let compressed = Double(stats.compressor_page_count) * Double(vm_page_size);
            let purgeable = Double(stats.purgeable_count) * Double(vm_page_size);
            let external = Double(stats.external_page_count) * Double(vm_page_size);
            let swapins = Int64(stats.swapins);
            let swapouts = Int64(stats.swapouts);
            
            self.used = active + inactive + speculative + wired + compressed - purgeable - external;
            self.free = self.total - used;
            self.swapins = swapins;
            self.swapouts = swapouts;
            
        }
        
    }
    
}
