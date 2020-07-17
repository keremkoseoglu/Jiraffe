//
//  Model.swift
//  Jiraffe
//
//  Created by Dr. Kerem Koseoglu on 10.07.2020.
//  Copyright © 2020 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import Cocoa

class Model {
    public var reader: JiraReader
    
    init(app:NSApplication, filterOutput:FilterOutputModel) {
        self.reader = JiraReader(app:app, filterOutput:filterOutput)
    }

    func schedule() {
        reader.execute()
        let _ = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer() {
        reader.execute()
    }
}
