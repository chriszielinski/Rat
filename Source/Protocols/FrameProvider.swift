//
//  FrameProvider.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/24/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Foundation

protocol FrameProvider {
    var frameCount: Int { get }
    func delay(forFrame index: Int) -> TimeInterval
    func image(forFrame index: Int, size: NSSize) -> NSImage?
}
