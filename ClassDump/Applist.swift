//
//  AppRow.swift
//  ClassView
//
//  Created by ParadiseDuo on 2023/1/5.
//

import Foundation
import SwiftUI
import Frida

struct AppRow: View {
    var app: Applicaiton
    
    var body: some View {
        HStack(alignment: .center) {
            app.icon.resizable().frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(app.name)
                    .font(.title)
                Text(app.bundleid)
                    .font(.body)
            }
            .padding()
        }
        .padding()
    }
}


struct Applist: View {
    @State var apps: [Applicaiton]
    
    @State private var loading = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            List(apps) { app in
                AppRow(app: app)
                    .listStyle(SidebarListStyle())
                    .onTapGesture {
                        USBDeviceManager.shared.attach(bundleid: app.bundleid) { session in
                            self.loading.toggle()
                            Class().classes(handle: { success, result in
                                var sw: NewWindowController<Classlist>
                                if success {
                                    sw = NewWindowController(rootView: Classlist(datas: result))
                                } else {
                                    sw = NewWindowController(rootView: Classlist(datas: []))
                                }
                                sw.window?.title = "类名列表"
                                sw.showWindow(nil)
                                self.loading.toggle()
                            })
                        }
                    }
            }
            if loading {
                ProgressView("读取中......").padding(.all, 10)
            }
        }
        .padding()
    }
}
