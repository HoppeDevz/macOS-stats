//
//  wifi.service.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 22/04/25.
//

import Foundation

import CoreWLAN
import CoreLocation

class WifiService {
    
    let locationManager = 
        CLLocationManager()
    
    init() {
        locationManager.requestWhenInUseAuthorization();
    }
    
    private func parse_channel_band(_ band: CWChannelBand) -> String {
        
        switch (band) {
            case CWChannelBand.bandUnknown: return "UNKNOWN";
            case CWChannelBand.band2GHz: return "2GHz";
            case CWChannelBand.band5GHz: return "5GHz";
            case CWChannelBand.band6GHz: return "6GHz";
            default: return "UNKNOWN BY THE AGENT";
        }
        
    }
    
    private func parse_channel_width(_ width: CWChannelWidth) -> String {
        
        switch (width) {
            case CWChannelWidth.widthUnknown: return "UNKNOWN";
            case CWChannelWidth.width20MHz: return "20MHz";
            case CWChannelWidth.width40MHz: return "40MHz";
            case CWChannelWidth.width80MHz: return "80MHz";
            case CWChannelWidth.width160MHz: return "160MHz";
            default: return "UNKNOWN BY THE AGENT";
        }
        
    }
    
    public func read_nearby_wifi() -> [IWifi] {
            
        if let interface = CWWiFiClient.shared().interface() {
            
            do {
                
                var nearbyWiFiList: [IWifi] = [];
                
                let networks = try interface.scanForNetworks(withSSID: nil);
                let current_network = self.read_current_wifi();
                
                for network in networks {
                    
                    if network.ssid == nil || network.bssid == nil {
                        continue;
                    }
                    
                    if let current = current_network, current.bssid == network.bssid  {
                        
                        nearbyWiFiList.append(current);
                        continue;
                        
                    }
                    
                    let channel_number = network.wlanChannel?.channelNumber ?? 0;
                    let channel_band = network.wlanChannel?.channelBand ?? CWChannelBand.bandUnknown;
                    let channel_width = network.wlanChannel?.channelWidth ?? CWChannelWidth.widthUnknown;
                    
                    let nearby_wifi_record = IWifi(
                        ssid: network.ssid ?? "Unknown",
                        bssid: network.bssid ?? "Unknown",
                        rssi: network.rssiValue,
                        noise: network.noiseMeasurement,
                        quality_snr: network.rssiValue - network.noiseMeasurement,
                        channel_number: channel_number,
                        channel_band: self.parse_channel_band(channel_band),
                        channel_width: self.parse_channel_width(channel_width),
                        connected: false
                    )
                    
                    nearbyWiFiList.append(nearby_wifi_record);
                    
                }
                
                return nearbyWiFiList;
                
            } catch {
                
                return [];
                
            }
            
        }
        
        return [];
        
    }
    
    public func read_current_wifi() -> IWifi? {
        
        if let interface = CWWiFiClient.shared().interface() {
            
            let ssid = interface.ssid() ?? "Unknown";
            let bssid = interface.bssid() ?? "Unknown";
            let rssi = interface.rssiValue();
            let noise = interface.noiseMeasurement();
            
            let channel_number = interface.wlanChannel()?.channelNumber ?? 0;
            let channel_band = interface.wlanChannel()?.channelBand ?? CWChannelBand.bandUnknown;
            let channel_width = interface.wlanChannel()?.channelWidth ?? CWChannelWidth.widthUnknown;
            
            return IWifi(
                ssid: ssid,
                bssid: bssid,
                rssi: rssi,
                noise: noise,
                quality_snr: rssi - noise,
                channel_number: channel_number,
                channel_band: self.parse_channel_band(channel_band),
                channel_width: self.parse_channel_width(channel_width),
                connected: true
            );
            
        }
        
        return nil;
        
    }
    
}
