//
//  wifi.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 22/04/25.
//

import Foundation

struct IWifi {
    var ssid: String
    var bssid: String
    var rssi: Int
    var noise: Int
    var quality_snr: Int
    var channel_number: Int
    var channel_band: String
    var channel_width: String
    var connected: Bool
}
