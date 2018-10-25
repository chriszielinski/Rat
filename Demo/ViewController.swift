//
//  ViewController.swift
//  Demo
//
//  Created by Chris Zielinski on 10/22/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Cocoa
import Rat

class ViewController: NSViewController {

    enum Cursor: String, CaseIterable {
        case gif = "GIF"
        case apng = "APNG"
        case lottie = "Lottie"
        case system = "Click Window to Cycle"
    }

    @IBOutlet var label: NSTextField!

    var ratGIFCursor: RatCursorController!
    var elephantAPNGCursor: RatCursorController!
    var lottieCursor: RatCursorController!

    var activeCursor: Cursor = .system

    override func viewDidLoad() {
        super.viewDidLoad()

        let ratGIFCursorSize = NSSize(width: 100, height: 100)
        let ratGIFCursorHotSpot = NSPoint(x: ratGIFCursorSize.width / 2, y: -ratGIFCursorSize.height / 3)
        ratGIFCursor = try! RatCursorController(gifName: "pizza-rat",
                                                      cursorHotSpot: ratGIFCursorHotSpot,
                                                      cursorSize: ratGIFCursorSize)
        ratGIFCursor.doesAutomaticallyDismiss = true

        let elephantAPNGCursorSize = NSSize(width: 100, height: 100)
        let elephantAPNGCursorHotSpot = NSPoint(x: elephantAPNGCursorSize.width / 2,
                                                y: -elephantAPNGCursorSize.height / 3)
        elephantAPNGCursor = try! RatCursorController(apngName: "elephant",
                                                            cursorHotSpot: elephantAPNGCursorHotSpot,
                                                            cursorSize: elephantAPNGCursorSize)

        let popsicleScale: CGFloat = 4
        let popsicleMaxWidth = 10 * popsicleScale
        let popsicleMaxHeight = 18 * popsicleScale
        let popsicleCursorHotSpot = NSPoint(x: popsicleMaxWidth / 2, y: -popsicleMaxHeight / 3)
        let popsicleCursorSize = NSSize(width: 80 * popsicleScale, height: 60 * popsicleScale)
        let popsicleCropRect = NSRect(x: (popsicleCursorSize.width / 2) - (popsicleMaxWidth / 2),
                                      y: (popsicleCursorSize.height / 2) - (popsicleMaxHeight / 2),
                                      width: popsicleMaxWidth,
                                      height: popsicleMaxHeight)
        lottieCursor = RatCursorController(lottieAnimationName: "ice-cream",
                                           cropRect: popsicleCropRect,
                                           cursorHotSpot: popsicleCursorHotSpot,
                                           cursorSize: popsicleCursorSize)

        label.stringValue = activeCursor.rawValue
        view.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clickGestureRecognized)))
    }

    @objc
    func clickGestureRecognized() {
        switch activeCursor {
        case .gif:
            // Note: We don't have to dismiss `ratGIFCursor` because it `doesAutomaticallyDismiss`.
            elephantAPNGCursor.present()
            activeCursor = .apng
        case .apng:
            elephantAPNGCursor.dismiss()
            lottieCursor.present()
            activeCursor = .lottie
        case .lottie:
            lottieCursor.dismiss()
            activeCursor = .system
        case .system:
            ratGIFCursor.present()
            activeCursor = .gif
        }

        label.stringValue = activeCursor.rawValue
    }
}

