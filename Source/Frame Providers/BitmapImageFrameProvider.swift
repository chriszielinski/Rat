//
//  BitmapImageFrameProvider.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/24/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Cocoa

open class BitmapImageFrameProvider: FrameProvider {
    public let imageSource: CGImageSource
    public let frameCount: Int
    public var frameDelays: [TimeInterval]!

    public init(data: Data) throws {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil)
            else { throw RatError.noImages }

        self.imageSource = imageSource
        frameCount = CGImageSourceGetCount(imageSource)
        frameDelays = try decodeFrameDelays()
    }

    open func decodeFrameDelays() throws -> [TimeInterval] {
        fatalError("Must be implemented by subclass.")
    }

    open func delay(forFrame index: Int) -> TimeInterval {
        return frameDelays[index]
    }

    open func image(forFrame index: Int, size: NSSize) -> NSImage? {
        guard index < frameCount, let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
            else { return nil }

        let fittedSize: NSSize
        let aspectRatio: CGFloat = CGFloat(cgImage.width) / CGFloat(cgImage.height)
        if cgImage.width > cgImage.height {
            fittedSize = NSSize(width: size.width, height: size.width / aspectRatio)
        } else {
            fittedSize = NSSize(width: aspectRatio * size.height, height: size.height)
        }

        return NSImage(cgImage: cgImage, size: fittedSize)
    }

    /// Written by [Alexis Creuzot](https://github.com/kirualex) for [SwiftyGif](https://github.com/kirualex/SwiftyGif).
    ///
    /// The MIT License (MIT)
    ///
    /// Copyright (c) 2016 Alexis Creuzot
    ///
    /// Permission is hereby granted, free of charge, to any person obtaining a copy
    /// of this software and associated documentation files (the "Software"), to deal
    /// in the Software without restriction, including without limitation the rights
    /// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    /// copies of the Software, and to permit persons to whom the Software is
    /// furnished to do so, subject to the following conditions:
    ///
    /// The above copyright notice and this permission notice shall be included in all
    /// copies or substantial portions of the Software.
    ///
    /// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    /// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    /// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    /// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    /// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    /// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    /// SOFTWARE.
    open func delayTimes(dictionaryKey: CFString,
                         unclampedDelayTimeKey: CFString,
                         delayTimeKey: CFString) throws -> [TimeInterval] {
        let imageCount = CGImageSourceGetCount(imageSource)
        guard imageCount > 0 else {
            throw RatError.noImages
        }

        var imageProperties = [CFDictionary]()
        for frameIndex in 0..<imageCount {
            if let dict = CGImageSourceCopyPropertiesAtIndex(imageSource, frameIndex, nil) {
                imageProperties.append(dict)
            } else {
                throw RatError.noImageProperties
            }
        }

        let frameProperties = try imageProperties.map { (dict) -> CFDictionary in
            let key = Unmanaged.passUnretained(dictionaryKey).toOpaque()
            let value = CFDictionaryGetValue(dict, key)
            if value == nil {
                throw RatError.noImageDictionary
            }
            return unsafeBitCast(value, to: CFDictionary.self)
        }

        func convertToDelay(_ pointer: UnsafeRawPointer?) -> TimeInterval? {
            guard pointer != nil
                else { return nil }
            return unsafeBitCast(pointer, to: AnyObject.self).doubleValue
        }

        let EPS: Double = 1e-6
        let frameDelays: [TimeInterval] = try frameProperties.map {
            let unclampedKey = Unmanaged.passUnretained(unclampedDelayTimeKey).toOpaque()
            let unclampedPointer: UnsafeRawPointer? = CFDictionaryGetValue($0, unclampedKey)
            if let value = convertToDelay(unclampedPointer), value >= EPS {
                return value
            }

            let clampedKey = Unmanaged.passUnretained(delayTimeKey).toOpaque()
            let clampedPointer: UnsafeRawPointer? = CFDictionaryGetValue($0, clampedKey)
            if let value = convertToDelay(clampedPointer) {
                return value
            }

            throw RatError.noImageTimingInfo
        }

        return frameDelays
    }
}
