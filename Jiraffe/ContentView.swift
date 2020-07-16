//
//  ContentView.swift
//  Jiraffe
//
//  Created by Dr. Kerem Koseoglu on 10.07.2020.
//  Copyright © 2020 Dr. Kerem Koseoglu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    public var model: Model
    
    var body: some View {
        VStack {
            Text("Jiraffe - written by Dr. Kerem Koseoglu")
                
            Button(action: {
                self.model.reader.newItemCount = 0
                NSApp.dockTile.badgeLabel = ""
                self.model.reader.openJira()
            }) {
                Text("Clear")
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


/*struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView(Model())
    }
}*/
