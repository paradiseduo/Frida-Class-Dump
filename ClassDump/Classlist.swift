//
//  ClassList.swift
//  ClassView
//
//  Created by ParadiseDuo on 2023/1/5.
//

import Foundation
import SwiftUI

struct ClassName: Identifiable {
    var id: Int
    var name: String
}

struct Classlist: View {
    @State var datas: [ClassName]
    // 数据源
    @State private var dataSource: [ClassName] = []
    // 刷新状态绑定
    @State private var isRefreshing: Bool = false
    // 页码
    @State private var page: Int = 0
    
    @State private var loading = false
    
    private var refreshListener: some View {
      // 一个任意视图，我们将把它添置在滚动列表的尾部
      Text(isRefreshing ? "加载中": "")
          .frame(width: 150, height: 35) // height: 如果有加载动画就设置，没有设置为0就可以
          .onAppear(perform: {
              loadData()
          })
    }

    private func loadData() {
        isRefreshing = true
        var max = page + 200
        if max > datas.count {
            max = datas.count-1
        }
        if max < 0 {
            max = 0
        }
        dataSource += datas[page..<max]
        page = max
        isRefreshing = false
    }

    var body: some View {
        HStack(alignment: .center) {
            ScrollView(.vertical) {
                // 使用懒加载，确保滑动到再Appear。
                LazyVStack(alignment: .leading) {
                    ForEach(0..<dataSource.count, id: \.self) { index in
                        Text(dataSource[index].name).onTapGesture {
                            self.loading.toggle()
                            Method(className: dataSource[index].name).methods { success, result in
                                var sw: NewWindowController<Methodlist>
                                if success {
                                    sw = NewWindowController(rootView: Methodlist(datas: result))
                                } else {
                                    sw = NewWindowController(rootView: Methodlist(datas: []))
                                }
                                sw.window?.title = "方法列表"
                                sw.showWindow(nil)
                                self.loading.toggle()
                            }
                        }
                    }
                    // 加载更多
                    refreshListener
                }
            }
            .onAppear {
                // 页面出现获取数据
                loadData()
            }
            if loading {
                ProgressView("读取中......").padding(.all, 10)
            }
        }
    }
}
