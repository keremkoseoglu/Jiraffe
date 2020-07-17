//
//  AppDelegate.swift
//  Jiraffe
//
//  Created by Dr. Kerem Koseoglu on 10.07.2020.
//  Copyright © 2020 Dr. Kerem Koseoglu. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var model: Model!
    var filterOutput: FilterOutputModel!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        filterOutput = FilterOutputModel()
        model = Model(app: NSApp, filterOutput: filterOutput)
        let contentView = ContentView(model:model, filterOutput: filterOutput)
        model.schedule()
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.title = "Jiraffe"
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        return
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }


}

