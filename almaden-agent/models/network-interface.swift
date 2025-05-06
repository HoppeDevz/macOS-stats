//
//  interface.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 24/04/25.
//

import Foundation

struct INetworkInterface {
    var name: String
    var idx: UInt32? = nil
    var speed: UInt64? = nil
    var ipv4_addr: String? = nil
    var ipv6_addr: String? = nil
    var net_mask: String? = nil
    var mac_addr: String? = nil
}
