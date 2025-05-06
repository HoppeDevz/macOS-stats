//
//  byte-formatter.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import Foundation

struct ByteFormatter {
    
    static func string(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter(); formatter.countStyle = .file;
        return formatter.string(fromByteCount: bytes);
    }
    
}

