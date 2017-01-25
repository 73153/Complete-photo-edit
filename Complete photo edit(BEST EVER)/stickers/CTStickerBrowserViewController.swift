//
//  CTStickerBrowserViewController.swift
//  computer
//
//  Created by Nate Parrott on 9/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Messages

class CTStickerBrowserViewController: MSStickerBrowserViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
        NotificationCenter.default.addObserver(self, selector: #selector(CTStickerBrowserViewController.reload), name: NSNotification.Name(rawValue: "DidBecomeActive"), object: nil)
    }
    
    var stickers = [MSSticker]()
    
    func reload() {
        if let dir = StickerStore.Shared.directory {
            let contents = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])) ?? []
            stickers = contents.reversed().filter({ $0.pathExtension == "png" }).map({ (url) -> MSSticker? in
                return try? MSSticker(contentsOfFileURL: url, localizedDescription: "Sticker")
            }).filter({ $0 != nil }).map({ $0! })
        }
        stickerBrowserView.reloadData()
    }
    
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
    override var stickerSize: MSStickerSize {
        get {
            return .small
        }
    }
}
