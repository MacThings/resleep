//
//  Preferences.swift
//  Preferences
//
//  Created by Sascha Lamprecht on 10.06.2020.
//  Copyright © 2020 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class About: NSViewController {
  
    
    @IBOutlet weak var label_copyright: NSTextField!
    @IBOutlet weak var label_version: NSTextField!
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSApp.activate(ignoringOtherApps: true)
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let dateStr = formatter.string(from: NSDate() as Date)
        
        label_copyright.stringValue = "Copyright (" + dateStr + ") by Sascha Lamprecht"
        label_version.stringValue = "v" + appVersion!
        
    }

    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }

    @IBAction func goto_website(_ sender: Any) {
        print("web")
        let appId = ""
        let url = URL(string:"https://www.sl-soft.de")!
        NSWorkspace.shared.open([url],
                                withAppBundleIdentifier: appId,
                                options: [],
                                additionalEventParamDescriptor: nil,
                                launchIdentifiers: nil)
    }
    
    


}
