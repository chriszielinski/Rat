//
//  RatCursorController.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/22/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Foundation
import Lottie

open class RatCursorController: NSObject {
    private var animationTimer: Timer?

    let frameProvider: FrameProvider
    let cursorHotSpot: NSPoint
    let cursorSize: NSSize

    var currentLoop: Int = 0
    var currentFrame: Int = 0

    public private(set) var isActive: Bool = false
    /// Whether the cursor dismisses itself when another cursor is set.
    public var doesAutomaticallyDismiss: Bool = false
    public var loopCount: Int = 0
    public var doesLoop: Bool {
        return loopCount == 0
    }

    public init(gifData: Data,
                cursorHotSpot: NSPoint = .zero,
                cursorSize: NSSize = NSSize(width: 23, height: 23)) throws {
        self.cursorHotSpot = cursorHotSpot
        self.cursorSize = cursorSize

        frameProvider = try GIFFrameProvider(data: gifData)
    }

    public init(apngData: Data,
                cursorHotSpot: NSPoint = .zero,
                cursorSize: NSSize = NSSize(width: 23, height: 23)) throws {
        self.cursorHotSpot = cursorHotSpot
        self.cursorSize = cursorSize

        frameProvider = try APNGFrameProvider(data: apngData)
    }

    public init(model: LOTComposition?,
                in bundle: Bundle?,
                cropRect: NSRect? = nil,
                cursorHotSpot: NSPoint = .zero,
                cursorSize: NSSize = NSSize(width: 23, height: 23)) {
        self.cursorHotSpot = cursorHotSpot
        self.cursorSize = cursorSize

        frameProvider = LOTFrameProvider(model: model,
                                          in: bundle,
                                          imageSize: cursorSize,
                                          cropRect: cropRect)
    }

    convenience public init(gifURL: URL,
                            cursorHotSpot: NSPoint = .zero,
                            cursorSize: NSSize = NSSize(width: 23, height: 23)) throws {
        try self.init(gifData: try Data(contentsOf: gifURL), cursorHotSpot: cursorHotSpot, cursorSize: cursorSize)
    }

    convenience public init(gifName: String,
                            cursorHotSpot: NSPoint = .zero,
                            cursorSize: NSSize = NSSize(width: 23, height: 23)) throws {
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif")
            else { throw RatError.fileNotFound }
        try self.init(gifURL: url, cursorHotSpot: cursorHotSpot, cursorSize: cursorSize)
    }

    convenience public init(apngURL: URL,
                            cursorHotSpot: NSPoint = .zero,
                            cursorSize: NSSize = NSSize(width: 23, height: 23)) throws {
        try self.init(apngData: try Data(contentsOf: apngURL), cursorHotSpot: cursorHotSpot, cursorSize: cursorSize)
    }

    convenience public init(apngName: String,
                            cursorHotSpot: NSPoint = .zero,
                            cursorSize: NSSize = NSSize(width: 23, height: 23)) throws {
        guard let url = Bundle.main.url(forResource: apngName, withExtension: "png")
            else { throw RatError.fileNotFound }
        try self.init(apngURL: url, cursorHotSpot: cursorHotSpot, cursorSize: cursorSize)
    }

    convenience public init(lottieAnimationName: String,
                            bundle: Bundle? = nil,
                            cropRect: NSRect? = nil,
                            cursorHotSpot: NSPoint = .zero,
                            cursorSize: NSSize = NSSize(width: 23, height: 23)) {
        let composition: LOTComposition?
        if let bundle = bundle {
            composition = LOTComposition(name: lottieAnimationName, bundle: bundle)
        } else {
            composition = LOTComposition(name: lottieAnimationName)
        }

        self.init(model: composition,
                  in: bundle,
                  cropRect: cropRect,
                  cursorHotSpot: cursorHotSpot,
                  cursorSize: cursorSize)
    }

    func incrementCurrentFrame() {
        let newFrame = currentFrame + 1

        if !doesLoop {
            currentLoop += newFrame / frameProvider.frameCount
        }

        currentFrame = newFrame % frameProvider.frameCount
    }

    open func delayForCurrentFrame() -> TimeInterval {
        return frameProvider.delay(forFrame: currentFrame)
    }

    open func imageForNextValidFrame() -> NSImage {
        var failedAttempts = 0
        var frameImage = frameProvider.image(forFrame: currentFrame, size: cursorSize)

        while frameImage == nil && failedAttempts <= frameProvider.frameCount {
            failedAttempts += 1
            incrementCurrentFrame()
            frameImage = frameProvider.image(forFrame: currentFrame, size: cursorSize)
        }

        if failedAttempts > frameProvider.frameCount {
            return NSImage()
        }

        return frameImage!
    }

    open func createNextCursor() -> NSCursor? {
        incrementCurrentFrame()

        guard doesLoop || currentLoop < loopCount else {
            dismiss()
            return nil
        }

        return RatCursor(controller: self)
    }

    open func present() {
        isActive = true
        currentFrame = 0
        currentLoop = 0

        NSCursor.current.push()
        NSApp.windows.forEach { $0.disableCursorRects() }

        if let nextCursor = createNextCursor() {
            nextCursor.set()
            setAnimationTimer()
        } else {
            dismiss()
        }
    }

    open func dismiss(shouldRestoreCursorRects: Bool = true, shouldPop: Bool = true) {
        isActive = false
        animationTimer?.invalidate()

        if shouldRestoreCursorRects {
            NSApp.windows.forEach { $0.enableCursorRects() }
        }

        if shouldPop {
            NSCursor.pop()
        }
    }

    private func setAnimationTimer() {
        animationTimer = Timer.scheduledTimer(timeInterval: delayForCurrentFrame(),
                                     target: self,
                                     selector: #selector(updateCursor),
                                     userInfo: nil,
                                     repeats: false)
    }

    @objc
    func updateCursor() {
        guard isActive else { return }

        if doesAutomaticallyDismiss {
            if let currentRat = NSCursor.current as? RatCursor {
                if currentRat.controller != self {
                    return dismiss(shouldRestoreCursorRects: false, shouldPop: false)
                }
            } else {
                return dismiss(shouldPop: false)
            }
        }

        createNextCursor()?.set()
        setAnimationTimer()
    }
}
