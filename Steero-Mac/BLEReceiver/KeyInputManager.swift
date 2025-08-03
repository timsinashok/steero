//
//  KeyInputManager.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//

import Foundation
import CoreGraphics

class KeyInputManager {
    static func process(steer: Int8, throttle: UInt8) {
        let steerThreshold: Int8 = 30
        let throttleThreshold: UInt8 = 30

        // Right Arrow
        if steer > steerThreshold {
            sendKey(keyCode: 124, isDown: true)
        } else {
            sendKey(keyCode: 124, isDown: false)
        }

        // Left Arrow
        if steer < -steerThreshold {
            sendKey(keyCode: 123, isDown: true)
        } else {
            sendKey(keyCode: 123, isDown: false)
        }

        // Up Arrow
        if throttle > throttleThreshold {
            sendKey(keyCode: 126, isDown: true)
        } else {
            sendKey(keyCode: 126, isDown: false)
        }
    }

    private static func sendKey(keyCode: CGKeyCode, isDown: Bool) {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: isDown) else { return }
        event.post(tap: .cghidEventTap)
    }
}

