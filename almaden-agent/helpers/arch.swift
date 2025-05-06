//
//  arch.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 19/04/25.
//

import Foundation

struct Arch {
    
    static func isARM() -> Bool {
        
        var system_info = utsname();
        uname(&system_info);

        let mirror = 
            Mirror(reflecting: system_info.machine);
        
        let identifier = mirror.children.reduce("") { identifier, element in
            
            guard let value = element.value as? Int8, value != 0 else { return identifier };
            return identifier + String(UnicodeScalar(UInt8(value)));
            
        }
        
        return identifier == "arm64";
        
    }
}
