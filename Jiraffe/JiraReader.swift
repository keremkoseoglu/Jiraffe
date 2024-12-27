//
//  JiraReader.swift
//  Jiraffe
//
//  Created by Dr. Kerem Koseoglu on 16.07.2020.
//  Copyright © 2020 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import Cocoa

public struct IssueFields: Decodable {
    var summary: String
}

public struct Issue: Decodable {
    var id: String
    var key: String
    var fields: IssueFields
}

public struct Reply: Decodable {
    var total: Int
    var issues: [Issue]
}

public struct Filter: Decodable{
    var name: String
    var url: String
    var replied: Bool
    var reply: Reply
    var prevReply: Reply
}

public struct Filters: Decodable {
    var filters: [Filter]
}

public struct JiraAccount: Decodable {
    var webAlias: String
    var url: String
    var username: String
    var password: String
    var apiKey: String
    var projects: [String]
}

public struct JiraAccounts: Decodable {
    var accounts: [JiraAccount]
    
    public func getAccountByUrl(_ url: String) -> JiraAccount? {
        var cleanUrl = url.replacingOccurrences(of: "http://", with: "")
        cleanUrl = cleanUrl.replacingOccurrences(of: "https://", with: "")
        let roots = cleanUrl.split(separator: "/").map { String($0) }
        
        return accounts.first { $0.url.contains(roots[0]) }
    }
    
    public func getAccountByIssueKey(_ key: String) -> JiraAccount? {
        let projects = key.split(separator: "-").map { String($0) }
        return accounts.first { $0.projects.contains(projects[0]) }
    }

}

public protocol TicketSystemReader {
    var newItemCount: Int { get set }
    var filters: Filters { get set }
    
    func execute()
    func clearDucks()
    func openJira()
    func openJiraIssue(key: String)
}



public class MultiJiraReader: TicketSystemReader {
    public var newItemCount = 0
    public var filters = Filters(filters: [])
    
    private var app: NSApplication
    private var filterOutput: FilterOutputModel
    private var isReading = false
    private var duck = "🐣 "
    private var JIRAFFE_CONFIG = "/Users/Kerem/Documents/etc/config/jiraffe.json"
    private var ACC_CONFIG = "/Users/Kerem/Documents/etc/config/jiraffe_acc.json"
    private var jiraAccounts = JiraAccounts(accounts: [])
    
    init(app: NSApplication, filterOutput: FilterOutputModel) {
        self.app = app
        self.filterOutput = filterOutput
        readJiraffeConfig()
        readAccConfig()
    }
    
    public func execute() {
        DispatchQueue.main.async{
            if self.isReading {return}
            self.isReading = true
            
            for i in 0..<self.filters.filters.count {
                self.filters.filters[i].replied = false
            }
            
            for i in 0..<self.filters.filters.count {
                self.executeFilter(filter:self.filters.filters[i])
            }
        }
    }
    
    public func openJira() {
        for acc in self.jiraAccounts.accounts {
            NSWorkspace.shared.open(URL(string: acc.url)!)
        }
    }
    
    public func openJiraIssue(key: String) {
        let account = self.jiraAccounts.getAccountByIssueKey(key)!
        let url = account.url + "/browse/" + key
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    public func clearDucks() {
        for i in 0..<filters.filters.count {
            var issueIndex = -1
            for prevIssue in filters.filters[i].prevReply.issues {
                issueIndex += 1
                filters.filters[i].prevReply.issues[issueIndex].fields.summary = prevIssue.fields.summary.replacingOccurrences(of: duck, with: "")
            }
        }
    }
    
    private func readJiraffeConfig() {
        do {
            let jsonData = try String(contentsOfFile: JIRAFFE_CONFIG).data(using: .utf8)
            
            self.filters = try JSONDecoder().decode(Filters.self, from: jsonData!)
            
            for filter in self.filters.filters {
                let filterOutput = FilterOutput(name: filter.name, total: 0)
                self.filterOutput.append(item:filterOutput)
            }
            
        } catch let error {
            print(error)
        }
    }
    
    private func readAccConfig() {
        do {
            let jsonData = try String(contentsOfFile: ACC_CONFIG).data(using: .utf8)
            self.jiraAccounts = try JSONDecoder().decode(JiraAccounts.self, from: jsonData!)
            
        } catch let error {
            print(error)
        }
    }
    
    private func executeFilter(filter: Filter) {
        let url = URL(string: filter.url)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let account = self.jiraAccounts.getAccountByUrl(filter.url)!
        
        if account.password != "" {
            let loginString = String(format: "%@:%@", account.username, account.password)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        } else {
            let credentials = "\(account.username):\(account.apiKey)"
            let encodedCredentials = credentials.data(using: .utf8)!.base64EncodedString()
            request.addValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        }
         
        URLSession.shared.dataTask(with: request) { data, response, error in
           if let data = data {
               do {
                var jiraReply = try JSONDecoder().decode(Reply.self, from: data)
                self.evaluateJiraReply(filter:filter, reply:&jiraReply)
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
    
    private func evaluateJiraReply(filter: Filter, reply: inout Reply) {
        var thisItemCount = 0
        var issueIndex = -1
        
        for curIssue in reply.issues {
            issueIndex += 1
            var found = false
            for prevIssue in filter.prevReply.issues {
                if prevIssue.id == curIssue.id {
                    found=true
                    reply.issues[issueIndex].fields.summary = prevIssue.fields.summary // Preserve duck
                }
            }
            if !found {
                self.newItemCount += 1
                thisItemCount += 1
                reply.issues[issueIndex].fields.summary = duck + curIssue.fields.summary
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
    
    private func jiraReplyEvaluationCompleted() {
        DispatchQueue.main.sync {
            for filter in filters.filters {
                if !filter.replied {return}
            }
            
            if newItemCount > 0 {
                self.app.dockTile.badgeLabel = String(self.newItemCount)
                NSSound(named: "Purr")?.play()
            } else {
                self.app.dockTile.badgeLabel = ""
            }
            
            self.isReading = false
        }
    }
}
