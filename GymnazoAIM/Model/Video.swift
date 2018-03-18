//
//  Video.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/17/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation

class Video {
    var name: String?
    var databaseID: String?
    var databasePath: String?
    var storagePath: String?
    var url: URL
    var uploadDate: Date?
    var creationDate: Date?
    var notes: String?
    
    init(url: URL) {
        self.url = url
    }
}
