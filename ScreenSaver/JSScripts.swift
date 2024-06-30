//
//  JSScripts.swift
//  ScreenSaverGallery
//
//  Created by tomasjavurek on 28.05.2024.
//  Copyright © 2024 metazoa.org. All rights reserved.
//

import Foundation

class JSScripts {
    
    func logWithDelay(key: String, msg: String, delay: Int) -> String {
        return """
            setTimeout(() => {
                console.log('\(key)', '\(msg)')
            }, \(String(describing: delay)));
        """
    }
        
    let overrideConsole: String = """
            let devLogElm = null;
            window.addEventListener("load", () => {
                devLogElm = document.querySelector(".devlog-container");
            });

            function log(emoji, type, args) {
                window.webkit.messageHandlers.logHandler.postMessage(
                    `${emoji} JS ${type}: ${Object.values(args)
                        .map(v => typeof (v) === "undefined" ? "undefined" : typeof (v) === "object" ? JSON.stringify(v) : v.toString())
                        .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
                        .join(", ")}`
                )
            }

            function logToDevLog(emoji, args) {
                if (!devLogElm) return;
                const p = document.createElement("p");
                p.innerHTML = `<span class="key">${emoji} ${args["0"]}</span>: <span class="value">${args["1"]}</span>`;
                devLogElm.appendChild(p);
            }

            let originalLog = console.log
            let originalWarn = console.warn
            let originalError = console.error
            let originalDebug = console.debug

            console.log = function() {
                log("📗", "log", arguments);
                originalLog.apply(null, arguments);
                logToDevLog("📗", arguments);
            }
            console.warn = function() {
                log("📙", "warning", arguments);
                originalWarn.apply(null, arguments);
                logToDevLog("📙", arguments);
            }
            console.error = function() {
                log("📕", "error", arguments);
                originalError.apply(null, arguments);
                logToDevLog("📕", arguments);
            }
            console.debug = function() {
                log("📘", "debug", arguments);
                originalDebug.apply(null, arguments);
                logToDevLog("📘", arguments);
            }
            window.addEventListener("error", function (e) {
                log("💥", "Uncaught", [`${e.message} at ${e.filename}:${e.lineno}:${e.colno}`])
                logToDevLog("💥", {"0": "Uncaught", "1": `${e.message} at ${e.filename}:${e.lineno}:${e.colno}`});
            })
        """
}
