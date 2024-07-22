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
    let idKey: String = "id"
    let devModeKey: String = "ssgDevMode"
    let mutedKey: String = "muted"
    let sensitiveKey: String = "sensitive"
    let voiceOverKey: String = "voiceOver"
    // defaults
    var id: String = UUID().uuidString.lowercased()
    var developerMode: Bool = false // default
    var muted: Bool = false
    var sensitive: Bool = false
    var voiceOver: Bool = false
    
    
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
    @IBOutlet weak var sensitiveCheckbox: NSButton!
    @IBOutlet weak var voiceOverCheckbox: NSButton!
    @IBOutlet weak var checkForUpdateButton: NSButton!
    @IBOutlet weak var versionTextField: NSTextField!
    
    
    override init() {
        super.init()
        let bundle = Bundle(for: ScreenSaverGalleryConfig.self)
        bundle.loadNibNamed("SSGConfig", owner: self, topLevelObjects: nil)
        // load defaults and set developerMode
        userDefaults.register(defaults: [
            id: id,
            devModeKey: developerMode,
            mutedKey: muted,
            sensitiveKey: sensitive,
            voiceOverKey: voiceOver
        ])
        loadDefaults()
        // print("version",)
    }
    
    
    @objc fileprivate func loadDefaults() {
        // get saved defaults for devMode
        var id: String = userDefaults.string(forKey: idKey) ?? ""
        let devMode: Bool = userDefaults.bool(forKey: devModeKey)
        let mutedDef: Bool = userDefaults.bool(forKey: mutedKey)
        let sensitiveDef: Bool = userDefaults.bool(forKey: sensitiveKey)
        let voiceOverDef: Bool = userDefaults.bool(forKey: voiceOverKey)
    
        if (id.count == 0) {
            id = self.id
            saveStringToDefaults(key: idKey, value: id)
        } else {
            self.id = id
        }
        
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
        
        if (sensitiveDef == true) {
            sensitive = true
            sensitiveCheckbox.setNextState()
        } else {
            sensitive = false
        }
        
        if (voiceOverDef == true) {
            voiceOver = true
            voiceOverCheckbox.setNextState()
        } else {
            voiceOver = false
        }
        
    }
    
    @objc fileprivate func saveToDefaults(key: String, value: Bool) {
        userDefaults.set(value, forKey: key)
    }
    
    @objc fileprivate func saveStringToDefaults(key: String, value: String) {
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
    
    @objc fileprivate func toggleSensitive() {
        sensitive = !sensitive
        saveToDefaults(key: sensitiveKey, value: sensitive)
    }
    
    @objc fileprivate func toggleVoiceOver() {
        voiceOver = !voiceOver
        saveToDefaults(key: voiceOverKey, value: voiceOver)
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
    
    @IBAction func sensitiveDidChange(_ sender: NSButton) {
        toggleSensitive()
    }
    
    @IBAction func voiceOverDidChange(_ sender: NSButton) {
        toggleVoiceOver()
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
