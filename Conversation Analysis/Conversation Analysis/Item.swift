//
//  Item.swift
//  Conversation Analysis
//
//  Created by EJ on 2/24/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//
import UIKit
class Item: NSObject{
    var name: String?
    var serialNumber: String?
    let dateCreated: String
    
    init(name:String, serialNumber: String?){
        self.name = name
        self.serialNumber = serialNumber
        self.dateCreated = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .short, timeStyle: .short)
        
        super.init()
    }
    
    convenience init(random: Bool = false){
        if random {
            let graphNames = ["graph 1", "graph 2", "graph 3","graph 4","graph 5"]
            
            var index = arc4random_uniform(UInt32(graphNames.count))
            let randomGraphName = graphNames[Int(index)]
            let randomSerialNumber  = UUID().uuidString.components(separatedBy: "-").first!
            
            self.init(name:randomGraphName, serialNumber: randomSerialNumber)
        }
        else{
            self.init(name: "",serialNumber: nil)
        }
        
    }
}

