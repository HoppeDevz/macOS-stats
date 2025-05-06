//
//  SwapUsage.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 28/04/25.
//

import Foundation

struct ISwapUsage {
    var xsu_total: UInt64;
    var xsu_available: UInt64;
    var xsu_used: UInt64;
    var xsu_pagesize: UInt32;
    var encrypted: Bool;
}
