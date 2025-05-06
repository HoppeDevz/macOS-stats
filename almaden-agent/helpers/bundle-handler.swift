//
//  budle-handler.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 30/04/25.
//

import Foundation

struct BundleHandler {
    
    static let fs =
        FileManager();
    
    static func try_get_executable_main_bundle_path(_ executable_url: URL) -> URL? {
        
        let path_components = executable_url.pathComponents;
        
        var founded = false;
        var accumulator = "/";
        
        for component in path_components {
            
            accumulator = (accumulator as NSString).appendingPathComponent(component);
            if component.hasSuffix("app") { founded = true; break };
            
        }
        
        if founded {
            
            return URL(fileURLWithPath: accumulator);
            
        }
        
        return nil;
        
    }
    
    static func try_get_bundle_psinfo_path(_ bundle_path: URL) -> URL? {
        
        guard bundle_path.pathExtension == "app" else { return nil };
        
        let contents_path = bundle_path.appendingPathComponent("Contents/Info.plist");
        let wrapped_path = bundle_path.appendingPathComponent("WrappedBundle/Info.plist");
        
        if fs.fileExists(atPath: contents_path.path) {
            
            return contents_path;
            
        }
        
        if fs.fileExists(atPath: wrapped_path.path) {
            
            return wrapped_path;
            
        }
        
        return nil;
        
    }
    
    static func try_get_bundle_details(_ infoplist_path: String) -> IBundleDetails {
        
        let infoplist_url = URL(fileURLWithPath: infoplist_path);
        var infoplist_format = PropertyListSerialization.PropertyListFormat.xml;
        var details = IBundleDetails();
        
        guard
            let data = try? Data(contentsOf: infoplist_url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &infoplist_format),
            let dict = plist as? [String: Any] else { return details };
        
        details.CFBundleDisplayName          = dict["CFBundleDisplayName"] as? String
        details.CFBundleExecutable           = dict["CFBundleExecutable"] as? String
        details.CFBundleIconFile             = dict["CFBundleIconFile"] as? String
        details.CFBundleIdentifier           = dict["CFBundleIdentifier"] as? String
        details.CFBundleName                 = dict["CFBundleName"] as? String
        details.CFBundlePackageType          = dict["CFBundlePackageType"] as? String
        details.CFBundleShortVersionString   = dict["CFBundleShortVersionString"] as? String
        details.CFBundleVersion              = dict["CFBundleVersion"] as? String
        details.LSMinimumSystemVersion       = dict["LSMinimumSystemVersion"] as? String
        
        return details;
        
    }
    
}
