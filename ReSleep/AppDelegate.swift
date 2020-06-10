//
//  AppDelegate.swift
//  ReSleep
//
//  Created by Sascha Lamprecht on 10.06.2020.
//  Copyright © 2020 Sascha Lamprecht. All rights reserved.
//

import Cocoa
import LoginServiceKit
import LetsMove
import ShellOut
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate {
        
    //strong reference to retain the status bar item object
	var statusItem: NSStatusItem?
    
    @IBOutlet weak var appMenu: NSMenu!
    @IBOutlet weak var menu_countdown: NSMenuItem!
    
    var player: AVAudioPlayer?
    var countdownTimer: Timer!
       
    //var totalTime = (UserDefaults.standard.string(forKey: "Time")! as NSString).integerValue
    var totalTime = 5
    
    func startTimer() {
        self.menu_countdown.isEnabled = true
        self.menu_countdown.isHidden = false
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        RunLoop.main.add(countdownTimer!, forMode: .common)
    }
    
    
    @objc func updateTime() {
        UserDefaults.standard.set(true, forKey: "Running")
        let myMenu = self.menu_countdown
        myMenu!.title = "⏱️ " + "\(timeFormatted(totalTime))"
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
            do {
                try shellOut(to: "pmset", arguments: ["sleepnow"])
                } catch {
                    let error = error as! ShellOutError
                    print(error.message)
                    print(error.output)
                }
            endTimer()
            totalTime = (UserDefaults.standard.string(forKey: "TimeInfinite")! as NSString).integerValue
            startTimer()
        }
    }

    
    func endTimer() {
        countdownTimer.invalidate()
    }

   
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
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
        
        let countdown_check = UserDefaults.standard.string(forKey: "TimeInfinite")
        if countdown_check == nil{
            UserDefaults.standard.set("90", forKey: "TimeInfinite")
        }
        
        let init_check = UserDefaults.standard.string(forKey: "TimeInit")
        if init_check == nil{
            UserDefaults.standard.set("5", forKey: "TimeInit")
        }

        let immediately = UserDefaults.standard.string(forKey: "Immediately")
        if immediately == nil{
            UserDefaults.standard.set(false, forKey: "Immediatley")
        }
        
        menu_countdown.isHidden = true
        
        UserDefaults.standard.set(false, forKey: "Running")
        
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
        let immediately_check = UserDefaults.standard.bool(forKey: "Immediately")
        if immediately_check == true {
            startTimer()
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        UserDefaults.standard.set(false, forKey: "Running")
    }
    
    public func check_timeinit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func detect_mouse_button(sender: NSStatusItem) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.rightMouseUp{
            self.displayMenu()
        } else {
            let run_check = UserDefaults.standard.bool(forKey: "Running")
            if run_check == false {
                self.startTimer()
                let sound_check = UserDefaults.standard.bool(forKey: "Sound")
                if sound_check == true {
                playSoundNotify()
                }
            }
        }
    }
    
    
    @IBAction func quit_menubar(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

    
    @IBAction func kill_task(_ sender: Any) {
        let sound_check = UserDefaults.standard.bool(forKey: "Sound")
        if sound_check == true {
        playSoundStop()
        }
        endTimer()
        UserDefaults.standard.set(false, forKey: "Running")
        totalTime = 5
        self.menu_countdown.isHidden = true
    }
   
    func playSoundNotify() {
        let url = Bundle.main.url(forResource: "notification", withExtension: "mp3")!

        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }

            player.prepareToPlay()
            player.play()

        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func playSoundStop() {
        let url = Bundle.main.url(forResource: "stop", withExtension: "mp3")!

        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }

            player.prepareToPlay()
            player.play()

        } catch let error as NSError {
            print(error.description)
        }
    }
    
}


