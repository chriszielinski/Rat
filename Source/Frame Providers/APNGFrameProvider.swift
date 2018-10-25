//
//  APNGFrameProvider.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/24/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

open class APNGFrameProvider: BitmapImageFrameProvider {
    override open func decodeFrameDelays() throws -> [TimeInterval] {
        return try delayTimes(dictionaryKey: kCGImagePropertyPNGDictionary,
                              unclampedDelayTimeKey: kCGImagePropertyAPNGUnclampedDelayTime,
                              delayTimeKey: kCGImagePropertyAPNGDelayTime)
    }
}
