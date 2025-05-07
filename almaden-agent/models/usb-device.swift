//
//  usb-device.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 06/05/25.
//

import Foundation

struct IUSBDevice {
    var id: String;
    var product_name: String?;
    var vendor_name: String?;
    var serial_number: String?;
    var speed: UInt32?;
}
