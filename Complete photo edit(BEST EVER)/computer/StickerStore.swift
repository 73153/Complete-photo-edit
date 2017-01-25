//
//  StickerStore.swift
//  computer
//
//  Created by Nate Parrott on 9/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class StickerStore: NSObject {
    static let Shared = StickerStore()
    
    @objc class func getShared() -> StickerStore {
        return StickerStore.Shared
    }
    
    @objc var directory: URL? {
        get {
            if let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.nateparrott.sticker-app")?.appendingPathComponent("Stickers") {
                if !FileManager.default.fileExists(atPath: dir.path) {
                    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
                }
                return dir
            } else {
                return nil
            }
        }
    }
}
