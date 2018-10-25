//
//  RatCursor.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/24/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Cocoa

open class RatCursor: NSCursor {
    public let controller: RatCursorController

    public init(controller: RatCursorController) {
        self.controller = controller
        super.init(image: controller.imageForNextValidFrame(), hotSpot: controller.cursorHotSpot)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func pop() {
        controller.dismiss()
    }
}
