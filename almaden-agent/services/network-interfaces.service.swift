//
//  network-interfaces.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 23/04/25.
//

import Foundation

class NetworkInterfacesService {
    
    public func get_interface_idx(_ name: String) -> UInt32? {
        
        var idx: UInt32 = 0;
        
        name.utf8CString.withUnsafeBytes {
            idx = if_nametoindex($0.baseAddress);
        }
        
        guard 0 < idx else { return nil }; return idx;
        
    }
    
    public func get_interface_speed(_ idx: UInt32) -> UInt64? {
        
        var MIB: [Int32] = [
            CTL_NET,
            PF_LINK,
            NETLINK_GENERIC,
            IFMIB_IFDATA,
            Int32(idx),
            IFDATA_GENERAL
        ];
        
        let MIBSize = UInt32(MIB.count);
        
        var data = ifmibdata();
        var size = MemoryLayout<ifmibdata>.size;
        var speed : UInt64? = nil;
        
        MIB.withUnsafeMutableBufferPointer {
            
            let status = sysctl($0.baseAddress, MIBSize, &data, &size, nil, 0);
            
            if status == 0 {
                speed = data.ifmd_data.ifi_baudrate;
            }
            
        }
        
        return speed;
        
    }
    
    public func read() -> [INetworkInterface] {
        
        var interfaces: [INetworkInterface] = [];
        var ifaddr_pointer: UnsafeMutablePointer<ifaddrs>? = nil;
        
        if getifaddrs(&ifaddr_pointer) != 0 {
            return [];
        }
        
        var current = ifaddr_pointer;
        
        while current != nil {
            
            guard let ifa = current?.pointee else { break };
            
            let name = String(cString: ifa.ifa_name);
            let addr = ifa.ifa_addr.pointee;
            let family = addr.sa_family;
            
            let targetIndex = interfaces.firstIndex(where: { $0.name == name })
                ?? append_and_return(INetworkInterface(name: name, idx: self.get_interface_idx(name)), &interfaces);
            
            if family == UInt8(AF_INET) {
                
                let addr4 = ifa.ifa_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee };
                let ipv4 = String(cString: inet_ntoa(addr4.sin_addr));
                
                let nmask = ifa.ifa_netmask.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee };
                let netmask = String(cString: inet_ntoa(nmask.sin_addr));
                
                interfaces[targetIndex].ipv4_addr = ipv4;
                interfaces[targetIndex].net_mask = netmask;
                
            }
            
            if family == UInt8(AF_INET6) {
                
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST));
                let result = getnameinfo(ifa.ifa_addr, socklen_t(ifa.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST);
                
                if result == 0 {
                    
                    let ipv6 = String(cString: hostname);
                    interfaces[targetIndex].ipv6_addr = ipv6;
                    
                }
            }
            
            
            if family == UInt8(AF_LINK) {
                
                let dl = unsafeBitCast(ifa.ifa_addr, to: UnsafePointer<sockaddr_dl>.self);
                let pdata = withUnsafePointer(to: dl.pointee.sdl_data) { UnsafeRawPointer($0) };
                let pmac = pdata.advanced(by: Int(dl.pointee.sdl_nlen)).bindMemory(to: UInt8.self, capacity: Int(dl.pointee.sdl_alen));
                let buffer = [UInt8](UnsafeBufferPointer(start: pmac, count: Int(dl.pointee.sdl_alen)));
                let mac_addr = buffer.map { String(format: "%02hhx", $0) }.joined(separator: ":");
                
                interfaces[targetIndex].mac_addr = mac_addr;
                
            }
            
            
            current = ifa.ifa_next;
            
        }
        
        for i in 0..<interfaces.count {
            
            if let index = interfaces[i].idx, let speed = self.get_interface_speed(index) {
                interfaces[i].idx = index;
                interfaces[i].speed = speed;
                
            }
        }
        
        return interfaces;
        
    }
    
}
