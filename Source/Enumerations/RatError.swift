//
//  RatError.swift
//  Rat 🐀
//
//  Created by Chris Zielinski on 10/24/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Foundation

public enum RatError: Error {
    case fileNotFound
    case noImages
    case noImageProperties
    case noImageDictionary
    case noImageTimingInfo
}
