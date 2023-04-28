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
            let ss = api + """
            var defaultClass = ObjC.classes['\(className)']
            
            function getClassProperty(defaultClass) {
                var ivarCount = Memory.alloc(Process.pointerSize);
                var ivarHandles = api.class_copyIvarList(defaultClass, ivarCount);
                try {
                    const numIvars = ivarCount.readUInt();
                    for (let i = 0; i !== numIvars; i++) {
                        const handle = ivarHandles.add(i * Process.pointerSize).readPointer();
                        const name = api.ivar_getName(handle).readUtf8String();
                        const type = api.ivar_getTypeEncoding(handle).readUtf8String();
                        console.log(type, name);
                    }
                } finally {
                    api.free(ivarHandles);
                }
            }

            function getInstanceMehtod(defaultClass) {
                var className = api.class_getName(defaultClass).readUtf8String();
                var numMethodsBuf = Memory.alloc(Process.pointerSize);
                var methodHandles = api.class_copyMethodList(defaultClass, numMethodsBuf);
                try {
                    var numMethods = numMethodsBuf.readUInt();
                    for (let i = 0; i !== numMethods; i++) {
                        var methodHandle = methodHandles.add(i * Process.pointerSize).readPointer();
                        var sel = api.method_getName(methodHandle);
                        var nativeName = api.sel_getName(sel).readUtf8String();
                        console.log("-[" + className + " " + nativeName + "] " + "("+ api.method_getImplementation(methodHandle) +")");
                    }
                } finally {
                    api.free(methodHandles);
                }
            }

            function getClassMehtod(defaultClass) {
                var className = api.class_getName(defaultClass).readUtf8String();
                var numMethodsBuf = Memory.alloc(Process.pointerSize);
                var metaClass = api.object_getClass(defaultClass);
                var methodHandles = api.class_copyMethodList(metaClass, numMethodsBuf);
                try {
                    var numMethods = numMethodsBuf.readUInt();
                    for (let i = 0; i !== numMethods; i++) {
                        var methodHandle = methodHandles.add(i * Process.pointerSize).readPointer();
                        var sel = api.method_getName(methodHandle);
                        var nativeName = api.sel_getName(sel).readUtf8String();
                        console.log("+[" + className + " " + nativeName + "] " + "("+ api.method_getImplementation(methodHandle) +")");
                    }
                } finally {
                    api.free(methodHandles);
                }
            }
            
            getClassProperty(defaultClass);
            getInstanceMehtod(defaultClass);
            getClassMehtod(defaultClass);
            
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


