//
//  ConfigureSheetController.swift
//  ScreenSaverGallery
//
//  Created by Tomas Javurek on 01/11/2018.
//  Copyright © 2018 metazoa.org. All rights reserved.
//
import Foundation
import AppKit
import WebKit
import ScreenSaver


@objc(ScreenSaverGalleryConfig)
class ScreenSaverGalleryConfig: NSObject {
    // shared instance
    static let sharedInstance = ScreenSaverGalleryConfig()
    //
    
    let devModeKey: String = "ssgDevMode"
    let mutedKey: String = "muted"
    let adultKey: String = "adult"
    // defaults
    var developerMode: Bool = false // default
    var muted: Bool = false
    var adult: Bool = false
    
    
    lazy var userDefaults: UserDefaults = {
        let module = "org.metazoa.screensavergallery"
        
        guard let userDefaults = UserDefaults(suiteName: module) else {
            print("Couldn't create ScreenSaverDefaults, creating generic UserDefaults")
            return UserDefaults()
        }
        
        return userDefaults
    }()
    
    @IBOutlet var window: NSPanel!
    @IBOutlet weak var devModeCheckbox: NSButton!
    @IBOutlet weak var mutedCheckbox: NSButton!
    @IBOutlet weak var adultCheckbox: NSButton!
    @IBOutlet weak var checkForUpdateButton: NSButton!
    
    
    
    override init() {
        super.init()
        let bundle = Bundle(for: ScreenSaverGalleryConfig.self)
        bundle.loadNibNamed("SSGConfig", owner: self, topLevelObjects: nil)
        // load defaults and set developerMode
        userDefaults.register(defaults: [devModeKey: developerMode, mutedKey: muted, adultKey: adult])
        loadDefaults()
    }
    
    
    @objc fileprivate func loadDefaults() {
        // get saved defaults for devMode
        let devMode: Bool = userDefaults.bool(forKey: devModeKey)
        let mutedDef: Bool = userDefaults.bool(forKey: mutedKey)
        let adultDef: Bool = userDefaults.bool(forKey: adultKey)
        
        if (devMode == true) {
            developerMode = true
            devModeCheckbox.setNextState()
        } else {
            // checkbox is false by default
            developerMode = false
        }
        
        if (mutedDef == true) {
            muted = true
            mutedCheckbox.setNextState()
        } else {
            muted = false
        }
        
        if (adultDef == true) {
            adult = true
            adultCheckbox.setNextState()
        } else {
            adult = false
        }
        
        
    }
    
    @objc fileprivate func saveToDefaults(key: String, value: Bool) {
        userDefaults.set(value, forKey: key)
    }
    
    @objc fileprivate func toggleDeveloperMode() {
        developerMode = !developerMode
        // save to defaults
        saveToDefaults(key: devModeKey, value: developerMode)
    }
    
    @objc fileprivate func toggleMuted() {
        muted = !muted
        saveToDefaults(key: mutedKey, value: muted)
    }
    
    @objc fileprivate func toggleAdult() {
        adult = !adult
        saveToDefaults(key: adultKey, value: adult)
    }
    
    @IBAction func closeConfigPane(_ sender: NSButton) {
        window.sheetParent!.endSheet(window, returnCode: NSApplication.ModalResponse.OK)
    }

    // listen to user change checkbox
    @IBAction func developerModeDidChange(_ sender: NSButton) {
        // print("developerModeDidChange")
        toggleDeveloperMode()
    }
    
    @IBAction func mutedDidChange(_ sender: NSButton) {
        toggleMuted()
    }
    
    @IBAction func adultDidChange(_ sender: NSButton) {
        toggleAdult()
    }
    
    @IBAction func supportSSG(_ sender: NSButton) {
        if let url = URL(string: "https://screensaver.gallery/support-us?app=mac") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func openDiscord(_ sender: NSButton) {
        if let url = URL(string: "https://discord.com/invite/QJtRUYptRR") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func applyToCall(_ sender: NSButton) {
        if let url = URL(string: "https://screensaver.gallery/continuous-open-call?app=mac") {
            NSWorkspace.shared.open(url)
        }
    }

}
