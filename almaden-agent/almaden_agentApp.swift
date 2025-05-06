//
//  almaden_agentApp.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 17/04/25.
//

import SwiftUI

@main
struct almaden_agentApp: App {
    var body: some Scene {
        WindowGroup("Almaden macOS Agent") {
            ContentView()
                .background(WindowAccessor())
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                window.styleMask.remove(.resizable)
                window.setContentSize(NSSize(width: 700, height: 700))
            }
        }
        return NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

