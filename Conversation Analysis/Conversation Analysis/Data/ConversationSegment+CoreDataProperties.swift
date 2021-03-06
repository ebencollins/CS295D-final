//
//  ConversationSegment+CoreDataProperties.swift
//  Conversation Analysis
//
//  Created by Eben Collins on 2020-3-21.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//
//

import Foundation
import CoreData


extension ConversationSegment {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConversationSegment> {
        return NSFetchRequest<ConversationSegment>(entityName: "ConversationSegment")
    }
    
    @NSManaged public var duration: Int32
    @NSManaged public var uuid: UUID
    @NSManaged public var start_time: Int32
    @NSManaged public var conversation: Conversation?
    
    var image:URL {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return basePath.appendingPathComponent("images").appendingPathComponent("\(uuid).png")
    }
    
}
