//
//  MethoedScript.swift
//  ClassView
//
//  Created by ParadiseDuo on 2023/1/5.
//

import Foundation
import Frida

class Method : ScriptDelegate {
    private var script: Script?
    private var methods: [MethodName] = []
    let className: String
    
    init(className: String) {
        self.className = className
    }

    func scriptDestroyed(_: Script) {
        
    }

    func script(_: Script, didReceiveMessage message: Any, withData data: Data?) {
        if let dic = message as? NSDictionary, let p = dic["payload"] as? String {
            methods.append(MethodName(id: methods.count, name: p))
        }
    }
    
    func methods(handle: @escaping (Bool, [MethodName])->()) {
        if let session = USBDeviceManager.shared.session {
            let ss = """
            var methods = ObjC.classes['\(className)'].$ownMethods;
            for (var i = 0; i < methods.length; i++){
                console.log(methods[i]);
            }
            """
            session.createScript(ss, name: "MethodRead") { scriptResult in
                do {
                    self.script = try scriptResult()
                    self.script?.delegate = self
                    self.script?.load() { sresult in
                        do {
                            if try sresult() {
                                print("\(self.className) MethodRead Script loaded")
                                handle(true, self.methods)
                            } else {
                                print("\(self.className) Script loaded failed")
                                handle(false, self.methods)
                            }
                        } catch {
                            handle(false, self.methods)
                        }
                    }
                } catch {
                    handle(false, self.methods)
                }
            }
        } else {
            handle(false, self.methods)
        }
    }
}


