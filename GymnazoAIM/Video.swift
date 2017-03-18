//
//  Video.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/17/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation

class Video {
    var id: String?
    var name: String?
    var url: URL
    var uploadDate: Date?
    var creationDate: Date?
    
    init(url: URL) {
        self.url = url
    }
}
