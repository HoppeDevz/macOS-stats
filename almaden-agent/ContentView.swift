//
//  ContentView.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var system_info = 
        SystemInfoViewModel();
    
    @StateObject private var cpu_consumption =
        CpuConsumptionViewModel();
    
    @StateObject private var ram_consumption = 
        RamMemoryConsumptionViewModel();
    
    @StateObject private var storage_consumption = 
        StorageConsumptionViewModel();
    
    @StateObject private var battery_consumption =
        BatteryConsumptionViewModel();
    
    @StateObject private var wifi_info =
        WifiViewmodel();
    
    @StateObject private var network_interfaces =
        NetworkInterfacesViewmodel();
    
    @StateObject private var processes =
        ProcessesViewmodel();
    
    @StateObject private var geolocation =
        GeolocationViewmodel();
    
    @StateObject private var applications =
        ApplicationsViewmodel();
    
//    @StateObject private var usbevents =
//        USBViewmodel();
    
    @StateObject private var connected_devices =
        USBDevicesViewmodel();
    
    func format_interface_speed(_ speed: UInt64?) -> String {
        
        if let pspeed = speed {
            
            return "\(String(format: "%.2f", Double(pspeed) / 1024 / 1024)) Mbps";
            
        }
        
        return "0 Mbps";
        
    }
    
    var body: some View {
        
        ScrollView {
        
            ZStack {
                
                Image("alma_avatar")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .position(x: 540, y: 50)
            
                VStack(alignment: .leading, spacing: 12) {
                    
                    // System Info
                    Text("🖥️ **System Info**").font(.headline)
                    Text("🔹 Machine ID: \(system_info.system_info?.machine_id ?? "UNKNOWN")")
                    Text("🔹 Host Name: \(system_info.system_info?.host_name ?? "UNKNOWN")")
                    Text("🔹 OS: \(system_info.system_info?.os_name ?? "UNKNOWN")")
                    Text("🔹 Version: \(system_info.system_info?.os_version ?? "UNKNOWN")")
                    Text("🔹 Geolocation: (lat: \(geolocation.geolocation?.lat ?? 0)deg | long: \(geolocation.geolocation?.long ?? 0)deg)")
                    
                    Divider()
                    
                    // CPU
                    Text("🧠 **CPU**").font(.headline)
                    Text("🔹 CPU%: \(String(format: "%.2f", (cpu_consumption.cpu_consumption?.total ?? 0) * 100))%")
                    
                    Divider()
                    
                    // RAM
                    VStack(alignment: .leading, spacing: 10) {
                            
                        Text("💾 **RAM Memory**").font(.headline)
                        
                        HStack(alignment: .top, spacing: 20) {
                            
                            VStack(alignment: .leading, spacing: 5) {
                                
                                Text("🔹 Free RAM: \(ByteFormatter.string(Int64(ram_consumption.ram_memory_consumption?.free ?? 0)))")
                                Text("🔹 Used RAM: \(ByteFormatter.string(Int64(ram_consumption.ram_memory_consumption?.used ?? 0)))")
                                Text("🔹 Total RAM: \(ByteFormatter.string(Int64(ram_consumption.ram_memory_consumption?.total ?? 0)))")
                            }
                            .frame(width: 150, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("🔹 Swap In: \(ram_consumption.ram_memory_consumption?.swap_in ?? 0)")
                                Text("🔹 Swap Out: \(ram_consumption.ram_memory_consumption?.swap_out ?? 0)")
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("🔹 Swap Total: \(String(format: "%.2f", Double(ram_consumption.ram_memory_consumption?.vm_total ?? 0) / 1024 / 1024 / 1024 )) GB")
                                
                                Text("🔹 Swap Used: \(String(format: "%.2f", Double(ram_consumption.ram_memory_consumption?.vm_used ?? 0) / 1024 / 1024 / 1024 )) GB")
                                
                                Text("🔹 Swap Free: \(String(format: "%.2f", Double(ram_consumption.ram_memory_consumption?.vm_free ?? 0) / 1024 / 1024 / 1024 )) GB")
                            }

                        }
                        
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        
                        HStack(alignment: .top, spacing: 20) {
                            
                            // Battery
                            VStack(alignment: .leading, spacing: 5) {
                                Text("🔋 **Battery**").font(.headline)
                                Text("🔹 Level: \(String(format: "%.0f", (self.battery_consumption.battery_info?.level ?? 0) * 100))%")
                                Text("🔹 Cycles: \(self.battery_consumption.battery_info?.cycles ?? 0)")
                                Text("🔹 Health: \(self.battery_consumption.battery_info?.health ?? 0)")
                            }
                            .frame(width: 150, alignment: .leading)
                            
                            // Storage
                            VStack(alignment: .leading, spacing: 5) {
                                Text("📦 **Storage**").font(.headline)
                                
                                ForEach(self.storage_consumption.volumes, id: \.BSDName) { item in
                                    
                                    Text("\(item.BSDName) ( \(String(format: "%.2f", Double(item.used) / 1024 / 1024 / 1024))GB / \(String(format: "%.2f", Double(item.size) / 1024 / 1024 / 1024))GB ) (\(item.file_type))");
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text("📡 **Network(\(self.wifi_info.nearby_wifi.count))**").font(.headline)
                        
                        ScrollView(.horizontal) {
                            
                            HStack {
                                
                                ForEach(self.wifi_info.nearby_wifi, id: \.bssid) { item in
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("🔹 SSID: \(item.ssid)")
                                        Text("🔹 BSSID: \(item.bssid)")
                                        Text("🔹 RSSI: \(item.rssi) dBm")
                                        Text("🔹 Noise: \(item.noise) dBm")
                                        Text("🔹 SNR: \(item.quality_snr) dBm")
                                        Text("🔹 Channel: \(item.channel_number)")
                                        Text("🔹 Channel Band: \(item.channel_band)")
                                        Text("🔹 Channel Width: \(item.channel_width)")
                                        Text("🔹 Connected: \(item.connected)")
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                        
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text("🧩 **Interfaces(\(self.network_interfaces.interfaces.count))**").font(.headline)
                        
                        ScrollView(.horizontal) {
                            
                            HStack {
                                
                                ForEach(self.network_interfaces.interfaces, id: \.name) { item in
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("🔹 Name: \(item.name)")
                                        Text("🔹 IPV4: \(item.ipv4_addr ?? "None")")
                                        Text("🔹 IPV6: \(item.ipv6_addr ?? "None")")
                                        Text("🔹 MAC: \(item.mac_addr ?? "None")")
                                        Text("🔹 Net Mask: \(item.net_mask ?? "None")")
                                        Text("🔹 Speed: \(self.format_interface_speed(item.speed))")
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("🧵 **Processes(\(self.processes.processes.count))**").font(.headline)
                        
                        ScrollView(.horizontal) {
                            
                            HStack {
                                
                                ForEach(self.processes.processes, id: \.pid) { item in
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("🔹 PID: \(item.pid)")
                                        Text("🔹 Name: \(item.name)")
                                        Text("🔹 App ID: \(item.appid)")
                                        
                                        Text("🔹 CPU% Single Core: \(String(format: "%.2f", item.cpu_single_core_percent * 100))%")
                                        Text("🔹 CPU% Multi Core: \(String(format: "%.2f", item.cpu_multi_core_percent * 100))%")
                                        
                                        Text("🔹 Physical Memory: \(String(format: "%.2f", Double(item.memory_consumption) / 1024 / 1024 / 1024))GB")
                                        Text("🔹 Physical% Memory: \(String(format: "%.2f", item.memory_percent * 100))%")
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                    Divider();
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("🧵 **Applications(\(self.applications.applications.count))**").font(.headline)
                        
                        ScrollView(.horizontal) {
                            
                            HStack {
                                
                                ForEach(self.applications.applications, id: \.name) { item in
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("🔹 Name: \(item.name)")
                                        Text("🔹 Scope: \(item.scope)")
                                        Text("🔹 Executable Name: \(item.details.CFBundleExecutable ?? "N.A")")
                                        Text("🔹 Bundle ID: \(item.details.CFBundleIdentifier ?? "N.A")")
                                        Text("🔹 Bundle Name: \(item.details.CFBundleName ?? "N.A")")
                                        Text("🔹 Bundle Display Name: \(item.details.CFBundleDisplayName ?? "N.A")")
                                        Text("🔹 Bundle Version: \(item.details.CFBundleVersion ?? "N.A")")
                                        Text("🔹 Bundle Minimum System Version: \(item.details.LSMinimumSystemVersion ?? "N.A")")
                                        Text("🔹 Bundle Path: \(item.bundle_path)")
                                    }
                                }
                            }
                        }
                    }
                    
//                    Divider();
//                    
//                    VStack(alignment: .leading, spacing: 10) {
//                        
//                        Text("🔌 **USB Events(\(self.usbevents.events.count))**").font(.headline)
//                        
//                        ScrollView(.horizontal) {
//                            
//                            HStack {
//                                
//                                ForEach(self.usbevents.events, id: \.id) { item in
//                                    
//                                    VStack(alignment: .leading, spacing: 5) {
//                                        Text("🔹 Type: \(item.event_type)")
//                                        Text("🔹 Product Name: \(item.product_name ?? "N.A")")
//                                        Text("🔹 Vendor Name: \(item.vendor_name ?? "N.A")")
//                                        Text("🔹 Serial Number: \(item.serial_number ?? "N.A")")
//                                        Text("🔹 Speed: \(item.speed ?? 0)")
//                                    }
//                                }
//                            }
//                        }
//                    }
                    
                    Divider();
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("🔌 **USB Devices(\(self.connected_devices.connected_devices.count))**").font(.headline)
                        
                        ScrollView(.horizontal) {
                            
                            HStack {
                                
                                ForEach(self.connected_devices.connected_devices, id: \.id) { item in
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("🔹 Product Name: \(item.product_name ?? "N.A")")
                                        Text("🔹 Vendor Name: \(item.vendor_name ?? "N.A")")
                                        Text("🔹 Serial Number: \(item.serial_number ?? "N.A")")
                                        Text("🔹 Speed: \(item.speed ?? 0)")
                                    }
                                }
                            }
                        }
                    }
                    
                }
                .frame(width: 600)
                
            }
            
        }
        .frame(width: 600, height: 600)
        
    }
    
}

#Preview {
    ContentView()
}
