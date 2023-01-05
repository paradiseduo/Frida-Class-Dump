//
//  ClassScript.swift
//  ClassView
//
//  Created by ParadiseDuo on 2023/1/5.
//

import Foundation
import Frida

class Class : ScriptDelegate {
    private var script: Script?
    private var classes: [ClassName] = []

    func scriptDestroyed(_: Script) {
        
    }

    func script(_: Script, didReceiveMessage message: Any, withData data: Data?) {
        if let dic = message as? NSDictionary, let p = dic["payload"] as? String {
            classes.append(ClassName(id: classes.count, name: p))
        }
    }
    
    func classes(handle: @escaping (Bool, [ClassName])->()) {
        if let session = USBDeviceManager.shared.session {
            let s = """
            for (var className in ObjC.classes)
            {
                console.log(className);
            }
            """
            session.createScript(s, name: "ClassRead") { scriptResult in
                do {
                    self.script = try scriptResult()
                    self.script?.delegate = self
                    self.script?.load() { sresult in
                        do {
                            if try sresult() {
                                print("ClassRead Script loaded")
                                handle(true, self.classes)
                            } else {
                                print("Script loaded failed")
                                handle(false, self.classes)
                            }
                        } catch {
                            handle(false, self.classes)
                        }
                    }
                } catch {
                    handle(false, self.classes)
                }
            }
        } else {
            handle(false, [])
        }
    }
}

