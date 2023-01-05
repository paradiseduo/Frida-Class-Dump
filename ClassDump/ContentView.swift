//
//  ContentView.swift
//  ClassDump
//
//  Created by ParadiseDuo on 2023/1/5.
//

import SwiftUI
import Frida

struct ContentView: View {
    @State var applications: [Applicaiton]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("ClassDump")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .onAppear {
                    USBDeviceManager.listUSBDevice { devices in
                        if let dd = devices.first {
                            USBDeviceManager.shared.listApplication(device: dd) { apps in
                                applications = apps
                            }
                        }
                    }
                }
            
            if applications.count == 0 {
                Applist(apps: applications).hidden()
            } else {
                Applist(apps: applications)
            }
            
        }.padding()
    }
}
