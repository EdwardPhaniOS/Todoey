//
//  Item.swift
//  Todoey
//
//  Created by Tan Vinh Phan on 11/26/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //Declare a reverse relationship
    //from: 1 ItemCategory -> many items: [Item]
    //to : 1 ItemCategory <- many items: [Item]
    var parentCategory = LinkingObjects(fromType: ItemCategory.self, property: "items")
    
}

