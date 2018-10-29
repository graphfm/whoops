//
//  Setting.swift
//  Whoops
//
//  Created by Anna Koczur on 27/10/2018.
//  Copyright © 2018 Anna Koczur. All rights reserved.
//

import Foundation
import RealmSwift

class Setting: Object {
    @objc dynamic var key = ""
    @objc dynamic var value = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
}
