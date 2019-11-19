//
//  Item.swift
//  Todoey
//
//  Created by Tan Vinh Phan on 11/18/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import Foundation

struct Item: Codable {
    var title: String = ""
    var done: Bool = false
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}




