//
//  AppDelegate.swift
//  SSGPreview
//
//  Created by tomasjavurek on 25.05.2024.
//  Copyright © 2024 metazoa.org. All rights reserved.
//

import Cocoa
import WebKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    private var sheet: NSWindow?
    lazy var screenSaverGalleryConfig: ScreenSaverGalleryConfig = ScreenSaverGalleryConfig.sharedInstance

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1920, height: 1080),
            styleMask: [.miniaturizable, .closable, .resizable, .titled],
            backing: .buffered, defer: false)
        window.center()
        window.makeKeyAndOrderFront(nil)
        screenSaverGalleryConfig.developerMode = true
        let ssg = ScreenSaverGalleryView.init(frame: NSRect(x: 0, y: 0, width: 1920, height: 1080), isPreview: true)
        // let config = ScreenSaverGalleryConfig()
        window.contentView?.addSubview(ssg!)
        ssg!.startAnimation()
        // self.sheet = ssg!.configureSheet
        // self.sheet?.makeKeyAndOrderFront(ScreenSaverGalleryConfig.window)
    }
    
    func configureSheet() -> NSWindow {
        return screenSaverGalleryConfig.window
//        if self.sheet == nil {
//            let thisBundle = Bundle(for: type(of: self))
//            if !thisBundle.loadNibNamed("ScreenSaverGalleryConfig", owner: self, topLevelObjects: nil) {
//                print("Unable to load configuration sheet")
//            }
//            
//        }
//        return self.sheet!
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

