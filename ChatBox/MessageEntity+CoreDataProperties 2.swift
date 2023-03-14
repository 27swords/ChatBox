//
//  MessageEntity+CoreDataProperties.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 2/3/2023.
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var senderId: String?
    @NSManaged public var receiverId: String?
    @NSManaged public var messageId: String?
    @NSManaged public var text: String?
    @NSManaged public var sentDate: Date?

}

extension MessageEntity : Identifiable {

}
