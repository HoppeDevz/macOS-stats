//
//  terminal-parser.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 22/04/25.
//

import Foundation

struct TerminalParser {
    
    static public func parse_swap_usage(_ input: String) -> (total_bytes: Int64, used_bytes: Int64, free_bytes: Int64)? {
        
        let regex = try! NSRegularExpression(pattern: "(\\d+\\.\\d+)([A-Za-z]+)", options: [])
            
        let nsString = input as NSString
        let results = regex.matches(in: input, options: [], range: NSRange(location: 0, length: nsString.length))
            
        if results.count == 3 {
            
            let totalStr = nsString.substring(with: results[0].range)
            let usedStr = nsString.substring(with: results[1].range)
            let freeStr = nsString.substring(with: results[2].range)
            
            func convertToBytes(valueStr: String) -> Int64? {
                
                let components = valueStr.split(separator: "M")
                
                if let value = Double(components[0]) {
                    return Int64(value * 1024 * 1024)
                }
                
                return nil
                
            }
            
            if let totalBytes = convertToBytes(valueStr: totalStr),
                let usedBytes = convertToBytes(valueStr: usedStr),
                let freeBytes = convertToBytes(valueStr: freeStr) {
                return (totalBytes, usedBytes, freeBytes)
            }
        }
        
        return nil;
        
    }
    
}
