//
//  AppDelegate.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 04.11.2019.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa
import LoginServiceKit
import LetsMove

class AppDelegate: NSObject, NSApplicationDelegate {
        
    //strong reference to retain the status bar item object
	var statusItem: NSStatusItem?
    
    @IBOutlet weak var appMenu: NSMenu!
    
    @IBOutlet weak var menu_countdown: NSMenuItem!

    let scriptPath = Bundle.main.path(forResource: "/Script/Script", ofType: "command")!
    
    var countdownTimer: Timer!
    //var totalTime = (UserDefaults.standard.string(forKey: "Time")! as NSString).integerValue
    var totalTime = 5
    
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        RunLoop.main.add(countdownTimer!, forMode: .common)
    }
   
    @objc func updateTime() {
        let myMenu = self.menu_countdown
        myMenu!.title = "⏱️ " + "\(timeFormatted(totalTime))"
        self.menu_countdown.isHidden = false

           if totalTime != 0 {
               totalTime -= 1
           } else {
               endTimer()
               self.syncShellExec(path: self.scriptPath, args: ["fire_up"])
               self.menu_countdown.isHidden = true
           }
       }
   
    func endTimer() {
        countdownTimer.invalidate()
        totalTime = 50
        self.menu_countdown.isHidden = true
    }
   
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
    //  let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }



    @objc func displayMenu() {
        
        guard let button = statusItem?.button else { return }
        let x = button.frame.origin.x
        let y = button.frame.origin.y - 5
        let location = button.superview!.convert(NSMakePoint(x, y), to: nil)
        let w = button.window!
        let event = NSEvent.mouseEvent(with: .leftMouseDown,
                                       location: location,
                                       modifierFlags: NSEvent.ModifierFlags(rawValue: 0),
                                       timestamp: 0,
                                       windowNumber: w.windowNumber,
                                       context: w.graphicsContext,
                                       eventNumber: 0,
                                       clickCount: 1,
                                       pressure: 0)!
        NSMenu.popUpContextMenu(appMenu, with: event, for: button)
    }
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let check_time = UserDefaults.standard.string(forKey: "Time")
        if check_time == nil{
            UserDefaults.standard.string(forKey: "Time")
        }
        
        
        
        statusItem = NSStatusBar.system.statusItem(withLength: -1)
        
        guard let button = statusItem?.button else {
            print("Status bar item failed. Try removing some menu bar item.")
            NSApp.terminate(nil)
            return
        }
       
        enum InterfaceStyle : String {
           case Dark, Light

           init() {
              let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
              self = InterfaceStyle(rawValue: type)!
            }
        }

        let currentStyle = InterfaceStyle()
        
        if currentStyle.rawValue == "Light"{
            button.image = NSImage(named: "logo_28")
        } else{
            button.image = NSImage(named: "logo_dark_28")
        }
        
        button.target = self
        button.action = #selector(self.detect_mouse_button(sender:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        PFMoveToApplicationsFolderIfNecessary()
        
        let loginitem = UserDefaults.standard.bool(forKey: "Loginitem")
               if loginitem == true {
               LoginServiceKit.addLoginItems(at: Bundle.main.bundlePath)
               } else {
                   let isExistLoginItem = LoginServiceKit.isExistLoginItems(at: Bundle.main.bundlePath)
                       if isExistLoginItem == true {
                           LoginServiceKit.removeLoginItems(at: Bundle.main.bundlePath)
                       }
               }
    }

    @objc func detect_mouse_button(sender: NSStatusItem) {

        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.rightMouseUp{
            self.displayMenu()
        } else {
            self.startTimer()
        }
    }
    
    @IBAction func quit_menubar(_ sender: Any) {
                NSApplication.shared.terminate(self)
            }
   
    @IBAction func fire_up(_ sender: Any) {
        endTimer()
    }

    func syncShellExec(path: String, args: [String] = []) {
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        process.launch() // Start process
        process.waitUntilExit() // Wait for process to terminate.
    }
    
}


