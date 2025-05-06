//
//  application.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 29/04/25.
//

import Foundation

class EApplicationScope {
    static let USER: String =       "USER";
    static let SHARED: String =     "SHARED";
    static let SYSTEM: String =     "SYSTEM";
}

struct IApplicationsDirectory {
    let url: URL;
    let scope: String;
}

struct IApplicationSnapshot {
    let name: String;
    let scope: String;
    let bundle_path: String;
    let ps_info_path: String;
}

struct IApplication {
    let name: String;
    let scope: String;
    let bundle_path: String;
    let details: IBundleDetails;
}

struct IBundleDetails {
    var CFBundleDisplayName: String?;
    var CFBundleExecutable: String?
    var CFBundleIconFile: String?
    var CFBundleIdentifier: String?
    var CFBundleName: String?
    var CFBundlePackageType: String?
    var CFBundleShortVersionString: String?
    var CFBundleVersion: String?
    var LSMinimumSystemVersion: String?
}
