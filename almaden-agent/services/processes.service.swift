//
//  processes.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 25/04/25.
//

import Foundation
import AppKit

class ProcessesService {
    
    private func get_cores_count() -> Int {
        var count: UInt32 = 0;
        var size = MemoryLayout<UInt32>.size;
        sysctlbyname("hw.logicalcpu", &count, &size, nil, 0);
        return Int(count);
    }
    
    private func get_max_memory() -> UInt64 {
        
        var stats = host_basic_info();
        var count = UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size);
        
        let pstats = withUnsafeMutablePointer(to: &stats) { UnsafeMutableRawPointer($0) }
        let pint = pstats.bindMemory(to: integer_t.self, capacity: Int(count));

        let kerr: kern_return_t = host_info(mach_host_self(), HOST_BASIC_INFO, pint, &count);
        
        if kerr == KERN_SUCCESS {
            
            return stats.max_mem;
            
        }
        
        return 0;
            
    }
    
    private func take_snapshot() -> [IProcessSnapshot] {
        
        var snapshot: [IProcessSnapshot] = [];
        
        let first_samples = take_snapshot_samples(); Thread.sleep(forTimeInterval: 1.0);
        let second_samples = take_snapshot_samples();
        let cores_count = get_cores_count();
        let max_mem = get_max_memory();
        
        for proc in first_samples.procs {
            
            if let second_sample_record = second_samples.procs.first(where: { $0.pid == proc.pid }) {
                
                let delta_time = Double(second_samples.retrieved_at.uptimeNanoseconds - first_samples.retrieved_at.uptimeNanoseconds) / 1_000_000_000.0;
                let total_cpu_time = delta_time * Double(cores_count);
                let delta_cpu_time = Double(second_sample_record.cpu_time - proc.cpu_time) / 1_000_000_000.0;
                
                let cpu_single_core_usage_percent = (delta_cpu_time / delta_time);
                let cpu_multi_core_usage_percent = (delta_cpu_time / total_cpu_time);
                
                snapshot.append(IProcessSnapshot(
                    pid: proc.pid,
                    appid: proc.appid,
                    name: proc.name,
                    // icon: proc.icon,
                    cpu_single_core_percent: cpu_single_core_usage_percent,
                    cpu_multi_core_percent: cpu_multi_core_usage_percent,
                    
                    memory_consumption: proc.memory_consumption,
                    memory_percent: max_mem > 0 ? Double(proc.memory_consumption) / Double(max_mem) : 0,
                    
                    first_sample: proc,
                    second_sample: second_sample_record
                ));
                
            }
            
        }
        
        return snapshot;
        
    }
    
    private func take_snapshot_samples() -> IProcessesSnapshotSamples {
        
        var procs_snapshot: IProcessesSnapshotSamples = IProcessesSnapshotSamples();
        
        var time_base = mach_timebase_info_data_t();
        mach_timebase_info(&time_base);
        
        let pid_size = MemoryLayout<pid_t>.stride;
        let buff_size: Int32 = Int32(4096 * pid_size);
        
        let pids_count = Int(buff_size) / pid_size;
        var pids_buff = [pid_t](repeating: 0, count: pids_count);
        
        let pids_rbuff_size = proc_listpids(UInt32(PROC_ALL_PIDS), 0, &pids_buff, buff_size);
        let pids_rcount = Int(pids_rbuff_size) / MemoryLayout<pid_t>.stride;
        
        for i in 0..<pids_rcount {
            
            let pid = pids_buff[i];
            
            var proctask_info = proc_taskinfo();
            let proctask_info_size = MemoryLayout<proc_taskinfo>.size;
            
            let proc_name_buff_size = 1024;
            var proc_name_buff = [CChar](repeating: 0, count: proc_name_buff_size);
            
            let proc_executable_path_buff_size = 1024;
            var proc_executable_path_buff = [CChar](repeating: 0, count: proc_executable_path_buff_size);
            
            proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &proctask_info, Int32(proctask_info_size));
            proc_name(pid, &proc_name_buff, UInt32(proc_name_buff_size));
            proc_pidpath(pid, &proc_executable_path_buff, UInt32(proc_executable_path_buff_size));
            
            let procname = String(cString: proc_name_buff);
            guard procname != "" else { continue };
            
            let proc_executable_path = String(cString: proc_executable_path_buff);
            let proc_executable_url = URL(fileURLWithPath: proc_executable_path);
            let proc_bundle_url = proc_executable_url.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent();

            let procpsinfo_path = BundleHandler.try_get_bundle_psinfo_path(proc_bundle_url);
            let procbundle_details = procpsinfo_path.flatMap { BundleHandler.try_get_bundle_details($0.path) };
            
            
            
            let proc_pgid = getpgid(pid); 
            
            let shallowest_father_executable_path_buff_size = 1024;
            var shallowest_father_executable_path_buff = [CChar](repeating: 0, count: shallowest_father_executable_path_buff_size);
            
            let shallowest_father_name_buff_size = 1024;
            var shallowest_father_name_buff = [CChar](repeating: 0, count: shallowest_father_name_buff_size);
            
            proc_name(proc_pgid, &shallowest_father_name_buff, UInt32(shallowest_father_name_buff_size));
            proc_pidpath(proc_pgid, &shallowest_father_executable_path_buff, UInt32(shallowest_father_executable_path_buff_size));
            
//            let shallowest_father_name = String(cString: shallowest_father_name_buff);
//            let shallowest_father_executable_path = String(cString: shallowest_father_executable_path_buff);
//            let shallowest_father_executable_url = URL(fileURLWithPath: shallowest_father_executable_path);
//            let shallowest_father_bundle_url = shallowest_father_executable_url.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent();
//            
//            let shallowest_father_psinfo_path = BundleHandler.try_get_bundle_psinfo_path(shallowest_father_bundle_url);
//            let shallowest_father_bundle_details = shallowest_father_psinfo_path.flatMap { BundleHandler.try_get_bundle_details($0.path) };
            
            let main_bundle_url = BundleHandler.try_get_executable_main_bundle_path(proc_executable_url);
            let main_bundle_url_psinfo_path = main_bundle_url.flatMap { BundleHandler.try_get_bundle_psinfo_path($0) };
            let main_bundle_details = main_bundle_url_psinfo_path.flatMap { BundleHandler.try_get_bundle_details($0.path) };
            
            procs_snapshot.procs.append(IProcessSnapshotSample(
                pid: pid,
                appid: main_bundle_details?.CFBundleIdentifier,
                name: procname,
                // icon: NSWorkspace.shared.icon(forFile: proc_bundle_url.path),
                cpu_time: Double(proctask_info.pti_total_user + proctask_info.pti_total_system) * Double(time_base.numer / time_base.denom),
                memory_consumption: proctask_info.pti_resident_size
            ));
            
        }
        
        return procs_snapshot;
        
    }
    
    public func list_processes() -> [IProcessSnapshot] {
        
        let snapshot = self.take_snapshot();
        let ordered = snapshot.sorted { $0.name.lowercased() < $1.name.lowercased() }
        
        return ordered;
        
    }
    
}
