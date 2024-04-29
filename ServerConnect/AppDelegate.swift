//
//  AppDelegate.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 11/12/2021.
//

import Cocoa
import LaunchAtLogin

protocol PopoverCloseDelegate: AnyObject {
    func closePopover(sender: Any?)
}

@main
class AppDelegate: NSObject, NSApplicationDelegate, PopoverCloseDelegate {

    

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let runningApp =
            NSWorkspace.shared.runningApplications
                .filter { item in item.bundleIdentifier == Bundle.main.bundleIdentifier }
                .first { item in item.processIdentifier != getpid() }

        if let running = runningApp {
            running.forceTerminate()
            
            let alert = NSAlert()
            alert.messageText = "App was already running"
            alert.informativeText = "App was terminated."
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        
        if let button = self.statusItem.button {
            button.image = NSImage(named: "MenubarIcon")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        let vc = ViewController.newInstance()
        vc.popoverCloseDelegate = self
        
        self.popover.contentViewController = vc
        self.popover.behavior = .transient
        self.popover.animates = false
        LaunchAtLogin.isEnabled = true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func togglePopover(_ sender: NSStatusItem) {
        if self.popover.isShown {
            closePopover(sender: sender)
        }
        else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = self.statusItem.button {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }

    func closePopover(sender: Any?)  {
        self.popover.performClose(sender)
    }
}

