//
//  Video.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/17/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation

class Video {
    var name: String? // Name of video
    var databaseID: String? // Firebase identifier
    var databasePath: String? // Realtime Database path
    var storagePath: String? // Storage path
    var url: URL // AVAsset URL
    var uploadDate: Date? // Upload Date
    var creationDate: Date? // Creation Date
    var notes: String? // Video notes
    
    init(url: URL) {
        self.url = url
    }
}
