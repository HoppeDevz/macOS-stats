//
//  usb.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 02/05/25.
//

import Foundation

import IOKit
import IOKit.usb

func device_connected_event_handler(_ instance: UnsafeMutableRawPointer?, _ iterator: io_iterator_t) -> Void {
    
    while case let device = IOIteratorNext(iterator), device != IO_OBJECT_NULL {
        
        let product_name = IORegistryEntryCreateCFProperty(device, kUSBProductString as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String;
        let vendor_name = IORegistryEntryCreateCFProperty(device, kUSBVendorString as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String;
        let serial_number = IORegistryEntryCreateCFProperty(device, kUSBSerialNumberString as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String;
        let speed = IORegistryEntryCreateCFProperty(device, "Device Speed" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? NSNumber;
        
        USBService.events.append(IUSBEvent(
            id: UUID().uuidString,
            event_type: "DEVICE_CONNECTED",
            product_name: product_name,
            vendor_name: vendor_name,
            serial_number: serial_number,
            speed: UInt32(truncating: speed ?? 0)
        ));
        
        IOObjectRelease(device);
    }
    
}

func device_ejected_event_handler(_ instance: UnsafeMutableRawPointer?, _ iterator: io_iterator_t) -> Void {
    
    while case let device = IOIteratorNext(iterator), device != IO_OBJECT_NULL {
        
        let product_name = IORegistryEntryCreateCFProperty(device, kUSBProductString as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String;
        let vendor_name = IORegistryEntryCreateCFProperty(device, kUSBVendorString as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String;
        let serial_number = IORegistryEntryCreateCFProperty(device, kUSBSerialNumberString as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String;
        let speed = IORegistryEntryCreateCFProperty(device, "Device Speed" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? NSNumber;
        
        USBService.events.append(IUSBEvent(
            id: UUID().uuidString,
            event_type: "DEVICE_EJECTED",
            product_name: product_name,
            vendor_name: vendor_name,
            serial_number: serial_number,
            speed: UInt32(truncating: speed ?? 0)
        ));
        
        IOObjectRelease(device);
    }
    
}

class USBService {
    
    static var device_connected_iterator: io_iterator_t = 0;
    static var device_ejected_iterator: io_iterator_t = 0;
    static var events: [IUSBEvent] = [];
    
    static public func retrieve_events() -> [IUSBEvent] {
        
        return events;
        
    }
    
    static public func watch_usb_ports() {
        
        
        guard let matching_dict = IOServiceMatching(kIOUSBDeviceClassName) else {
           
            print ("Error while trying to create the matching_dict!");
            return;
            
        }
        
        guard let notify_port = IONotificationPortCreate(kIOMasterPortDefault) else {
            
            print("Error while trying to create notification port!");
            return;
            
        }
        
        let connected_event_status = IOServiceAddMatchingNotification(
            notify_port, kIOMatchedNotification, matching_dict,
            device_connected_event_handler, nil, &device_connected_iterator
        );
        let removed_event_status = IOServiceAddMatchingNotification(
            notify_port, kIOTerminatedNotification, matching_dict,
            device_ejected_event_handler, nil, &device_ejected_iterator
        );
        
        if connected_event_status != kIOReturnSuccess {
            
            print("Error while trying to add notification!");
            return;
            
        }
        if removed_event_status != kIOReturnSuccess {
            
            print("Error while trying to add notification!");
            return;
            
        }
        
        
        while case let device = IOIteratorNext(device_connected_iterator), device != IO_OBJECT_NULL {};
        while case let device = IOIteratorNext(device_ejected_iterator), device != IO_OBJECT_NULL {};
        
        CFRunLoopAddSource(
            CFRunLoopGetMain(),
            IONotificationPortGetRunLoopSource(notify_port).takeUnretainedValue(),
            .commonModes
        );

    }
    
}
