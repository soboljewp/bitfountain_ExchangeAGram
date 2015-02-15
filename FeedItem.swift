//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Patrick Dawson on 15.02.15.
//  Copyright (c) 2015 Patrick Dawson. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber

}
