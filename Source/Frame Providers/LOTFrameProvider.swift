//
//  LOTImageGenerator.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/23/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Cocoa
import Lottie

public class LOTFrameProvider: LOTAnimationView, FrameProvider {
    var imageSize: NSSize = NSSize(width: 23, height: 23)
    var frameImages: [Int: NSImage]!

    var startFrame: Int? {
        return sceneModel?.startFrame?.intValue
    }
    var endFrame: Int? {
        return sceneModel?.endFrame?.intValue
    }
    var frameRate: TimeInterval? {
        return sceneModel?.framerate?.doubleValue
    }
    var frameDelay: TimeInterval {
        guard let framerate = frameRate
            else { return 1 / 30.0 }
        return 1 / framerate
    }
    var frameRange: Range<Int>? {
        guard let startFrame = startFrame, let endFrame = endFrame
            else { return nil }
        return startFrame..<endFrame
    }
    var frameCount: Int {
        return frameRange?.count ?? 0
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public init(model: LOTComposition?, in bundle: Bundle?, imageSize: NSSize, cropRect: NSRect?) {
        super.init(model: model, in: bundle)

        self.imageSize = imageSize
        setFrameSize(imageSize)
        frameImages = generateFrameImages(cropRect: cropRect)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func delay(forFrame index: Int) -> TimeInterval {
        return frameDelay
    }

    func image(forFrame index: Int, size: NSSize) -> NSImage? {
        return frameImages[index]
    }

    func generateImage(forFrame index: Int, cropRect: NSRect?) -> NSImage? {
        setProgressWithFrame(NSNumber(value: index))
        forceDrawingUpdate()

        let image = NSImage(size: imageSize)
        image.lockFocusFlipped(true)
        layer?.render(in: NSGraphicsContext.current!.cgContext)
        image.unlockFocus()

        if let cropRect = cropRect {
            return image.crop(to: cropRect)
        }

        return image
    }

    func generateFrameImages(cropRect: NSRect?) -> [Int: NSImage] {
        guard let frameRange = frameRange
            else { return [:] }

        let frameImageTuples = frameRange.compactMap { (frameIndex) -> (Int, NSImage)? in
            guard let frameImage = generateImage(forFrame: frameIndex, cropRect: cropRect)
                else { return nil }
            return (frameIndex, frameImage)
        }
        return Dictionary(uniqueKeysWithValues: frameImageTuples)
    }
}
