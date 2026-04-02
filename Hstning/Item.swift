//
//  Item.swift
//  Hstning
//
//  Created by Guy-Georges Adou Bogolo on 4/2/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
