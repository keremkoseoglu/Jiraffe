//
//  ContentView.swift
//  Jiraffe
//
//  Created by Dr. Kerem Koseoglu on 10.07.2020.
//  Copyright © 2020 Dr. Kerem Koseoglu. All rights reserved.
//

import SwiftUI

struct FilterOutput: Identifiable {
    var id = UUID()
    var name: String
    var total: Int
}

class FilterOutputModel: ObservableObject {
    @Published var items = [FilterOutput]()
    
    public func append(item:FilterOutput) {
        items.append(item)
    }
    
    public func update(name:String, total:Int) {
        for i in 0..<items.count {
            if items[i].name == name {
                items[i].id = UUID()
                items[i].total += total
                return
            }
        }
    }
    
    public func reset() {
        for i in 0..<items.count {
            items[i].total = 0
        }
    }
}

struct FilterDetail: Identifiable {
    var id = UUID()
    var name: String
}

class FilterDetailModel: ObservableObject {
    @Published var items = [FilterDetail]()
    
    public func clear() {
        items = [FilterDetail]()
    }
    
    public func append(item:FilterDetail) {
        items.append(item)
    }
}

struct ContentView: View {
    public var model: Model
    @ObservedObject var filterOutput = FilterOutputModel()
    @ObservedObject var filterDetail = FilterDetailModel()
    
    func clearNotifications() {
        self.model.reader.newItemCount = 0
        NSApp.dockTile.badgeLabel = ""
        self.filterOutput.reset()
        filterDetail.clear()
    }
    
    func itemSelected(name: String) {
        filterDetail.clear()
        for i in 0..<self.model.reader.filters.filters.count {
            let filterCandidate = self.model.reader.filters.filters[i]
            if filterCandidate.name == name {
                for x in 0..<filterCandidate.prevReply.issues.count {
                    let issue = filterCandidate.prevReply.issues[x]
                    let name = issue.key + " - " + issue.fields.summary
                    let newDetail = FilterDetail(id: UUID(), name: name)
                    filterDetail.append(item: newDetail)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.model.reader.execute()
                }) {Text("👀")}
                
                Button(action: {
                    self.clearNotifications()
                }) {Text("🧻")}
                
                Button(action: {
                    self.clearNotifications()
                    self.model.reader.openJira()
                }) {Text("🌍")}
            }
            
            List() {
                ForEach (filterOutput.items) { item in
                    HStack {
                        Button(action: {
                            self.itemSelected(name: item.name)
                        }) {Text("🔬")}
                        Text(item.name)
                        Text(String(item.total))
                    }
                }
            }
            
            List() {
                ForEach (filterDetail.items) { detailItem in
                    HStack {
                        Text(detailItem.name)
                    }
                }
            }
                
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


/*struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView(Model())
    }
}*/
