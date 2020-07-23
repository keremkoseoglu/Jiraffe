//
//  JiraReader.swift
//  Jiraffe
//
//  Created by Dr. Kerem Koseoglu on 16.07.2020.
//  Copyright © 2020 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import Cocoa

struct IssueFields: Decodable {
    var summary: String
}

struct Issue: Decodable {
    var id: String
    var key: String
    var fields: IssueFields
}

struct Reply: Decodable {
    var total: Int
    var issues: [Issue]
}

struct Filter: Decodable{
    var name: String
    var url: String
    var replied: Bool
    var reply: Reply
    var prevReply: Reply
}

struct Filters: Decodable {
    var filters: [Filter]
}

class JiraReader {
    public var newItemCount = 0
    public var filters = Filters(filters: [])
    
    private var KUTAPADA_CONFIG = "/Users/Kerem/Dropbox/Apps/kutapada/kutapada.json"
    private var KUTAPADA_KEY = "Ecz - Jira"
    private var JIRAFFE_CONFIG = "/Users/Kerem/Documents/etc/config/jiraffe.json"
    private var jiraUser = ""
    private var jiraPass = ""
    private var app: NSApplication
    private var filterOutput: FilterOutputModel
    private var isReading = false
    
    init(app: NSApplication, filterOutput: FilterOutputModel) {
        self.app = app
        self.filterOutput = filterOutput
        readJiraffeConfig()
        readKutapadaConfig()
    }
    
    func readJiraffeConfig() {
        do {
            let jsonData = try String(contentsOfFile: JIRAFFE_CONFIG).data(using: .utf8)
            self.filters = try JSONDecoder().decode(Filters.self, from: jsonData!)
            
            for filter in self.filters.filters {
                let filterOutput = FilterOutput(name: filter.name, total: 0)
                self.filterOutput.append(item:filterOutput)
            }
        } catch {print(error)}
    }
    
    func readKutapadaConfig() {
        do {
            let jsonData = try String(contentsOfFile: KUTAPADA_CONFIG)
            let pwd = PasswordJsonParser()
            pwd.parseJson(JsonText: jsonData)
            let accounts = pwd.flatAccountList
            
            let key_length = KUTAPADA_KEY.count
            
            for account in accounts {
                if account.name.count >= key_length && account.name.prefix(key_length) == KUTAPADA_KEY {
                    let spl = account.name.components(separatedBy: " - ")
                    self.jiraUser = spl[spl.count-1]
                    self.jiraPass = account.credential
                }
            }
        } catch {print(error)}
    }
    
    func execute() {
        if self.isReading {return}
        self.isReading = true
        
        for i in 0..<filters.filters.count {
            filters.filters[i].replied = false
        }
        
        for i in 0..<filters.filters.count {
            executeFilter(filter:filters.filters[i])
        }
    }
    
    func executeFilter(filter: Filter) {
        let url = URL(string: filter.url)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let loginString = String(format: "%@:%@", self.jiraUser, self.jiraPass)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
         
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
         
        URLSession.shared.dataTask(with: request) { data, response, error in
           if let data = data {
               do {
                let jiraReply = try JSONDecoder().decode(Reply.self, from: data)
                self.evaluateJiraReply(filter:filter, reply:jiraReply)
               } catch let error {
                print(error)
                self.isReading = false
               }
            }
            if error != nil {
                self.isReading = false
            }
        }.resume()
    }
    
    func evaluateJiraReply(filter: Filter, reply: Reply) {
        var thisItemCount = 0
        
        for curIssue in reply.issues {
            var found = false
            for prevIssue in filter.prevReply.issues {
                if prevIssue.id == curIssue.id {found=true}
            }
            if !found {
                self.newItemCount += 1
                thisItemCount += 1
            }
        }
        
        for i in 0..<filters.filters.count {
            if filters.filters[i].name == filter.name {
                filters.filters[i].replied = true
                filters.filters[i].prevReply = reply
            }
        }
        
        self.filterOutput.update(name: filter.name, total: thisItemCount)
        jiraReplyEvaluationCompleted()
    }
    
    func jiraReplyEvaluationCompleted() {
        for filter in filters.filters {
            if !filter.replied {return}
        }
        
        if newItemCount > 0 {
            self.app.dockTile.badgeLabel = String(self.newItemCount)
        } else {
            self.app.dockTile.badgeLabel = ""
        }
        
        self.isReading = false
    }
    
    public func openJira() {
        let randomUrl = self.filters.filters[0].url
        let rootUrl = randomUrl.components(separatedBy: "/rest")[0]
        NSWorkspace.shared.open(URL(string: rootUrl)!)
    }
}
