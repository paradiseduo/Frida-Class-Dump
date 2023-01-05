//
//  SwiftUIView.swift
//  ClassView
//
//  Created by ParadiseDuo on 2023/1/5.
//

import SwiftUI

class NewWindowController<RootView : View>: NSWindowController {
    convenience init(rootView: RootView) {
        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 800, height: 600))
        window.styleMask.insert(NSWindow.StyleMask.resizable)
        window.center()
        self.init(window: window)
    }
}

