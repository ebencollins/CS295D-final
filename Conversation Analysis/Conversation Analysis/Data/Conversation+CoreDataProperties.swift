//
//  Conversation+CoreDataProperties.swift
//  Conversation Analysis
//
//  Created by Eben Collins on 2020-3-21.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//
//

import Foundation
import CoreData


extension Conversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conversation> {
        return NSFetchRequest<Conversation>(entityName: "Conversation")
    }

    @NSManaged public var date: Date?
    @NSManaged public var duration: Int32
    @NSManaged public var uploaded: Bool
    @NSManaged public var uuid: UUID?
    @NSManaged public var segments: NSSet?

}

// MARK: Generated accessors for segments
extension Conversation {

    @objc(addSegmentsObject:)
    @NSManaged public func addToSegments(_ value: ConversationSegment)

    @objc(removeSegmentsObject:)
    @NSManaged public func removeFromSegments(_ value: ConversationSegment)

    @objc(addSegments:)
    @NSManaged public func addToSegments(_ values: NSSet)

    @objc(removeSegments:)
    @NSManaged public func removeFromSegments(_ values: NSSet)

}
