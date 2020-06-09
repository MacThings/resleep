//
//  AppDelegate.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

let _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)

let notifysecs = UserDefaults.standard.string(forKey: "Time")
if notifysecs == nil{
    UserDefaults.standard.set("60", forKey: "Time")
}
