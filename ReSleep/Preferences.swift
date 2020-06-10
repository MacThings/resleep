//
//  Preferences.swift
//  Preferences
//
//  Created by Sascha Lamprecht on 10.06.2020.
//  Copyright © 2020 Sascha Lamprecht. All rights reserved.
//

import Cocoa
import LoginServiceKit

class Preferences: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        NSApp.activate(ignoringOtherApps: true)
        // Do view setup here.
    }

    @IBAction func ok_button(_ sender: Any) {
        let loginitem = UserDefaults.standard.bool(forKey: "Loginitem")
        if loginitem == true {
        LoginServiceKit.addLoginItems(at: Bundle.main.bundlePath)
        } else {
            let isExistLoginItem = LoginServiceKit.isExistLoginItems(at: Bundle.main.bundlePath)
                if isExistLoginItem == true {
                    LoginServiceKit.removeLoginItems(at: Bundle.main.bundlePath)
                }
        }
        self.view.window?.close()
    }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
}
