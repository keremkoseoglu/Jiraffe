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
    public var reader: TicketSystemReader
    
    init(app:NSApplication, filterOutput:FilterOutputModel, reader:TicketSystemReader) {
        self.reader = reader
    }

    func schedule() {
        reader.execute()
        let _ = Timer.scheduledTimer(timeInterval: 900, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer() {
        reader.execute()
    }
}
