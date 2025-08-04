//
//  KeyInputManager.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//

import Foundation
import CoreGraphics

class KeyInputManager {
    static func process(steer: Int8, throttle: UInt8, brake: UInt8) {
        let steerThreshold: Int8 = 1
        let throttleThreshold: UInt8 = 1
        let brakeThreshold: UInt8 = 0 // any nonzero brake engages

        // Right Arrow
        if steer > steerThreshold {
            sendKey(keyCode: 124, isDown: true)
            print("steering right")
        } else {
            sendKey(keyCode: 124, isDown: false)
        }

        // Left Arrow
        if steer < -steerThreshold {
            sendKey(keyCode: 123, isDown: true)
            print("steering left")
        } else {
            sendKey(keyCode: 123, isDown: false)
        }

        // Up Arrow (throttle)
        if throttle > throttleThreshold {
            sendKey(keyCode: 126, isDown: true)
            print("throttling up")
        } else {
            sendKey(keyCode: 126, isDown: false)
        }

        // Brake: example mapping to 'B' key (keyCode 11)
        if brake > brakeThreshold {
            sendKey(keyCode: 11, isDown: true)
            print("braking with value \(brake)")
        } else {
            sendKey(keyCode: 11, isDown: false)
        }
    }

    private static func sendKey(keyCode: CGKeyCode, isDown: Bool) {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: isDown) else { return }
        event.post(tap: .cghidEventTap)
    }
}
