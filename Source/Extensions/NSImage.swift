//
//  NSImage.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/24/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Cocoa

extension NSImage {
    ///  Copies and crops an image to the supplied size.
    ///
    /// - Authors:
    ///   * Written by [Raphael Hanneken](https://gist.github.com/raphaelhanneken).
    ///   * Modified by Chris Zielinski.
    /// - Parameter size: The size of the new image.
    /// - Returns: The cropped copy of the given image.
    func crop(to frame: NSRect) -> NSImage? {
        // Get the best representation of the image for the given cropping frame.
        guard let rep = bestRepresentation(for: frame, context: nil, hints: nil)
            else { return nil }

        // Create a new image with the new size
        let img = NSImage(size: frame.size)

        img.lockFocus()
        defer { img.unlockFocus() }

        guard rep.draw(in: NSRect(origin: .zero, size: frame.size),
                       from: frame,
                       operation: .copy,
                       fraction: 1,
                       respectFlipped: false,
                       hints: [:])
            else { return nil }

        // Return the cropped image.
        return img
    }
}
