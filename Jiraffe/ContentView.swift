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

struct ContentView: View {
    public var model: Model
    @ObservedObject var filterOutput = FilterOutputModel()
    
    func clearNotifications() {
        self.model.reader.newItemCount = 0
        NSApp.dockTile.badgeLabel = ""
        self.filterOutput.reset()
    }
    
    var body: some View {
        VStack {
            Text("Jiraffe - written by Dr. Kerem Koseoglu")
            
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
                        Text(item.name)
                        Text(String(item.total))
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
