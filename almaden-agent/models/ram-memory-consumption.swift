//
//  ram-memory.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import Foundation

struct IRamMemoryConsumption {
    
    var total: Double
    var used: Double
    var free: Double
    var swap_in: Int64
    var swap_out: Int64
    var vm_total: UInt64
    var vm_used: UInt64
    var vm_free: UInt64
    
}
