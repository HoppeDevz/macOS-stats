//
//  usb-devices.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 06/05/25.
//

import Foundation
import IOKit

class USBDevicesService {
    
    public func retrieve_connected_devices() -> [IUSBDevice] {
        
        var connected_devices: [IUSBDevice] = [];

        guard let matching_dict = IOServiceMatching(kIOUSBDeviceClassName) else {
            print("Error while trying to create matching dict!")
            return connected_devices
        }

        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMasterPortDefault, matching_dict, &iterator)

        guard result == KERN_SUCCESS else {
            print("IOServiceGetMatchingServices failed with code \(result)")
            return connected_devices
        }

        func getProperty<T>(_ key: String, for device: io_object_t) -> T? {
            IORegistryEntryCreateCFProperty(device, key as CFString, kCFAllocatorDefault, 0)?
                .takeRetainedValue() as? T
        }

        while case let device = IOIteratorNext(iterator), device != IO_OBJECT_NULL {
            defer { IOObjectRelease(device) }

            let product_name: String? = getProperty(kUSBProductString, for: device)
            let vendor_name: String? = getProperty(kUSBVendorString, for: device)
            let serial_number: String? = getProperty(kUSBSerialNumberString, for: device)
            let speed: NSNumber? = getProperty("Device Speed", for: device)

            connected_devices.append(IUSBDevice(
                id: UUID().uuidString,
                product_name: product_name,
                vendor_name: vendor_name,
                serial_number: serial_number,
                speed: UInt32(truncating: speed ?? 0)
            ))
        }

        IOObjectRelease(iterator);

        return connected_devices;
        
    }
    
}
