//
//  Application.swift
//  ClassView
//
//  Created by ParadiseDuo on 2023/1/5.
//

import Foundation
import SwiftUI

struct Applicaiton: Hashable, Identifiable {
    var id: Int

    var bundleid: String
    var name: String
    var pid: Int
    
    var iconImage: NSImage
    var icon: Image {
        Image(nsImage: iconImage)
    }
}
