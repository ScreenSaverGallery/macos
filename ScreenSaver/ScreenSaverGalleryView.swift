//
//  SSGSwiftView.swift
//  SSGSwift
//
//  Created by Tomas Javurek on 28/10/2018.
//  Copyright © 2018 metazoa.org. All rights reserved.
//
import Foundation
import WebKit
import ScreenSaver

@objc(ScreenSaverGalleryView)
class ScreenSaverGalleryView: ScreenSaverView, WKNavigationDelegate, WKScriptMessageHandler {
    
    static var sharedInstance = ScreenSaverGalleryView()
    private var ssgWebView: WKWebView!
    private var textField: NSTextField!
    private var mainURL: URL
    lazy var screenSaverGalleryConfig: ScreenSaverGalleryConfig = ScreenSaverGalleryConfig.sharedInstance
    // We use this for tentative Catalina bug workaround
    var originalWidth, originalHeight: CGFloat // see: https://github.com/JohnCoates/Aerial/blob/master/Aerial/Source/Views/AerialView.swift
    
    
    override init?(frame: NSRect, isPreview: Bool) {
        mainURL = URL(string: ssgUrl)!
        // legacyScreenSaver always return true for isPreview on Catalina
        // We need to detect and override ourselves
        // This is finally fixed in Ventura
        // see: https://github.com/JohnCoates/Aerial/blob/master/Aerial/Source/Views/AerialView.swift
        var preview = false
        self.originalWidth = frame.width
        self.originalHeight = frame.height

        if frame.width < 400 && frame.height < 300 {
            preview = true
        }
        
        super.init(frame: frame, isPreview: preview)!
        // SSGView.performGammaFade()
        makeWebView()
        // setup notifications
        setNotifications()
    }
    
    required init?(coder: NSCoder) {
        mainURL = URL(string: ssgUrl)!
        self.originalWidth = 0
        self.originalHeight = 0

        super.init(coder: coder)
        self.originalWidth = frame.width
        self.originalHeight = frame.height
        makeWebView()
        // setup notifications
        setNotifications()
    }
    
    deinit {
        print("deinit")
        clearNotifications()
        
    }
        
    override func startAnimation() {
        super.startAnimation()
        // change default url if ssg in developer mode
        if (screenSaverGalleryConfig.developerMode == true) {
            mainURL = URL.init(string: ssgUrlDev)! // developer ./dev
        }
        // create and load request
        let request = URLRequest(url: mainURL)
        if (!self.isPreview) { // do not load ssg in preview
            ssgWebView.load(request)
        } else { // load loacal content on preview
            loadLocalContent()
        }
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    
    
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        self.needsDisplay = true // https://stackoverflow.com/a/64468627
        // set red background while developerMode is enabled
        if (screenSaverGalleryConfig.developerMode == true) {
            let red: NSColor = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3)
            red.setFill()
            rect.fill()
        } else {
            let black: NSColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            black.setFill()
            rect.fill()
        }
    }
    
    override func animateOneFrame() {
        // print("animate one frame")
        super.animateOneFrame()
        self.needsDisplay = true // https://stackoverflow.com/a/64468627
    }
    
    
    @objc fileprivate func makeWebView() {
        // remove old views
        removeOldViews()
        // wkwebview configuration
        let webConfiguration: WKWebViewConfiguration = WKWebViewConfiguration()
        // store data to disk (see: https://stackoverflow.com/a/51736967)
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.suppressesIncrementalRendering = true
        webConfiguration.applicationNameForUserAgent = "ScreenSaverGallery  SSG/" + bundleVersion + " (" + bundleBuild + ")"
        
        // ssg config
        if (screenSaverGalleryConfig.developerMode == true) {
            // enable developer tools if ssg is in developer mode < 13.3
            webConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
            // init ssg webview (without override)
            ssgWebView = WKWebView(frame: self.bounds, configuration: webConfiguration)
            // enable developer tools if ssg is in developer mode > 13.3
            if #available(macOS 13.3, *) {
                ssgWebView.isInspectable = true
            } else {
                ssgWebView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
            }
            // log messages
            if (!self.isPreview) { // do not log on preview
                logWebView()
            }
        } else {
            // init ssg webview (WKWebView with overriden mouseEvents)
            ssgWebView = ScreenSaverGalleryWebView(frame: self.bounds, configuration: webConfiguration)
        }
        
        // config webview
        ssgWebView.autoresizingMask = [.width, .height]
        // do not draw background on webview (can be set by styles)
        ssgWebView.setValue(false, forKey: "drawsBackground")
        // ssgWebView.frame = bounds
        ssgWebView.navigationDelegate = self
        // add webview as subview
        addSubview(ssgWebView)
        // disable occlusion (hack for sonoma)
        if #available(macOS 14.0, *) { // TODO: test it on lower system
            ssgWebView.hack_disableWindowOcclusionDetection()
        }
    }
    
    
    private func removeSubview(view: WKWebView) {
        if (!self.isPreview) {
            if #available(macOS 12.0, *) {
                ssgWebView.pauseAllMediaPlayback()
            }
            ssgWebView.load(URLRequest(url: URL(string: "about:blank")!))
            ssgWebView.removeFromSuperview()
            ssgWebView = nil
        }
    }
    
    func removeOldViews() {
        for case let v as WKWebView in subviews {
            print("remove old view")
            ssgWebView = v
            ssgWebView.removeFromSuperview()
            ssgWebView = nil
        }
    }
    
    private func setMuted(muted: Bool) {
        let js: String = "navigator.muted = \(muted)"
        ssgWebView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    private func setAdult(adult: Bool) {
        let js: String = "navigator.adult = \(adult)"
        ssgWebView.evaluateJavaScript(js, completionHandler: nil)
    }
    // override default document.hidden = true
    private func unhideDocument() {
        let js: String = "document.hidden = false"
        ssgWebView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    func logToJSConsole(key: String, msg: String) {
        let js: String = JSScripts().logWithDelay(key: key, msg: msg, delay: 2000)
        ssgWebView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    private func setNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
                self, selector: #selector(onSleepNote(note:)),
                name: NSWorkspace.willSleepNotification, object: nil)
        
        DistributedNotificationCenter.default.addObserver(self,
            selector: #selector(ScreenSaverGalleryView.willStop(_:)),
            name: Notification.Name("com.apple.screensaver.willstop"), object: nil)
    }
    
    private func clearNotifications() {
        NotificationCenter.default.removeObserver(self)
        DistributedNotificationCenter.default.removeObserver(self)
    }
    
    private func logWebView() {
        let overrideConsole = JSScripts().overrideConsole
        let script = WKUserScript(source: overrideConsole, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        ssgWebView.configuration.userContentController.addUserScript(script)
        // register the bridge script that listens for the output
        ssgWebView.configuration.userContentController.add(self, name: "logHandler")
        
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            // print("LOG: body: \(message.body)")
            // textField.stringValue += "\(message.body)\n"
            // print("textField value", textField.stringValue)
        }
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        let controller = screenSaverGalleryConfig
        return controller.window
    }
    
    override func didAddSubview(_ subview: NSView) {
        // self.startAnimation() // not necessary -> engine calls it, ssgpreview as well
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return self
    }
    
    override func resignFirstResponder() -> Bool {
        return false
    }
    
    override var acceptsFirstResponder: Bool {
        return false
    }
    
    
    @objc func willStop(_ aNotification: Notification) {
        print("willStop")
        removeSubview(view: ssgWebView)
        clearNotifications()
        if #available(macOS 14.0, *) {
            if (!self.isPreview) {
                exit(0)
            }
        }
        
    }
    
    @objc func onSleepNote(note: Notification) {
        removeSubview(view: ssgWebView)
        clearNotifications()
        if #available(macOS 14.0, *) {
            exit(0)
        }
        
    }
    
    
    //MARK:- WKNavigationDelegate
    
    func webView(_: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // if any error, load local default screensaver
        print("didFailProvisionalNavigation error \(error)")
        // loadLocalContent() // <- if offline, should be cached by service worker (offline mode)
    }
    func webView(_: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // print("Started provisional navigation: \(String(describing: navigation))")
    }
    func webView(_: WKWebView, didFinish navigation: WKNavigation!) {
        // print("Finished navigation: \(String(describing: navigation))")
        setSSGUserAgentConfig() // additional, ssg specific parameters to userAgent (muted, adult, ...)
    }
    
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // print("Decide policy for navigation action: \(String(describing: navigationAction))")
        if navigationAction.targetFrame == nil {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func setSSGUserAgentConfig() {
        setMuted(muted: screenSaverGalleryConfig.muted)
        setAdult(adult: screenSaverGalleryConfig.adult)
        unhideDocument()
    }
    
    // GET PARAMS FROM BUNDLES
    // bundle version
    var bundleVersion: String = {
        if let version = Bundle(identifier: "org.metazoa.screensavergallery")?.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else if let version = Bundle(identifier: "org.metazoa.ssg.preview")?.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }

        return "?"
    }()
    // bundle build
    var bundleBuild: String = {
        if let build = Bundle(identifier: "org.metazoa.screensavergallery")?.infoDictionary?["CFBundleVersion"] as? String {
            return build
        } else if let build = Bundle(identifier: "org.metazoa.ssg.preview")?.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }

        return "?"
    }()
    // additional, ssg specific - ssg url
    var ssgUrl: String = {
        if let url = Bundle(identifier: "org.metazoa.screensavergallery")?.infoDictionary?["SSG_URL"] as? String {
            return url
        } else if let url = Bundle(identifier: "org.metazoa.ssg.preview")?.infoDictionary?["SSG_URL"] as? String {
            return url
        }

        return "?"
    }()
    // ssg dev url
    var ssgUrlDev: String = {
        if let url = Bundle(identifier: "org.metazoa.screensavergallery")?.infoDictionary?["SSG_URL_DEV"] as? String {
            return url
        } else if let url = Bundle(identifier: "org.metazoa.ssg.preview")?.infoDictionary?["SSG_URL_DEV"] as? String {
            return url
        }

        return "?"
    }()
        
    
    // load local content -> used in preview
    @objc fileprivate func loadLocalContent() {
        let bundle = Bundle(for: ScreenSaverGalleryView.self)
        let url = bundle.url(forResource:"default", withExtension:"html")
        let request = URLRequest(url: url!)
        ssgWebView.load(request)
    }
    
}

// overriding mouse interactions for webview (test, if it is still necessary)
@objc(ScreenSaverGalleryWebView)
class ScreenSaverGalleryWebView: WKWebView {
        
    override open func mouseDown(with event: NSEvent) {
        self.superview!.superview!.mouseDown(with: event)
    }
    
    override open func mouseMoved(with event: NSEvent) {
        print("mouseMoved")
        self.superview!.superview!.mouseMoved(with: event)
    }
    
    override open func mouseUp(with event: NSEvent) {
        self.superview!.superview!.mouseUp(with: event)
    }
    
    override open func rightMouseDown(with event: NSEvent) {
          self.superview!.superview!.rightMouseDown(with: event)
    }
    
    override open func mouseDragged(with event: NSEvent) {
        self.superview!.superview!.mouseDragged(with: event)
    }
}


