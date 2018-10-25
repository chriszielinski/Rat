//
//  GIFFrameProvider.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/24/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

open class GIFFrameProvider: BitmapImageFrameProvider {
    override open func decodeFrameDelays() throws -> [TimeInterval] {
        return try delayTimes(dictionaryKey: kCGImagePropertyGIFDictionary,
                              unclampedDelayTimeKey: kCGImagePropertyGIFUnclampedDelayTime,
                              delayTimeKey: kCGImagePropertyGIFDelayTime)
    }
}
