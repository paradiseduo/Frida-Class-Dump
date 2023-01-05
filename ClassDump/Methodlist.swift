//
//  MethodList.swift
//  ClassView
//
//  Created by ParadiseDuo on 2023/1/5.
//

import Foundation
import SwiftUI

struct MethodName: Identifiable {
    var id: Int
    var name: String
}


struct Methodlist: View {
    var datas: [MethodName]

    var body: some View {
        List(datas) { item in
            Text(item.name).onTapGesture {
                print(item.name)
            }
        }
        .padding()
    }
}
