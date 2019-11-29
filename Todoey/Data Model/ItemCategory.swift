//
//  ItemCategory.swift
//  Todoey
//
//  Created by Tan Vinh Phan on 11/26/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import Foundation
import RealmSwift

class ItemCategory: Object {
    @objc dynamic var name: String = ""
    
    //Declare Forward Relationship
    //1 ItemCategory has many items
    let items = List<Item>()
    
}
