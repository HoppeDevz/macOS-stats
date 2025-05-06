//
//  usb-event.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 05/05/25.
//

import Foundation

struct IUSBEvent {
    var id: String;
    var event_type: String;
    var product_name: String?;
    var vendor_name: String?;
    var serial_number: String?;
    var speed: UInt32?;
}
