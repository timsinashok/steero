//
//  MotionManager.swift
//  Steero-iOS
//
//  Created by Ashok Timsina on 8/2/25.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private var referenceAttitude: CMAttitude?

    @Published var roll: Double = 0
    @Published var pitch: Double = 0

    func startUpdates() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let attitude = motion?.attitude else { return }

            if let reference = self.referenceAttitude {
                attitude.multiply(byInverseOf: reference)
            }

            self.roll = attitude.roll
            self.pitch = attitude.pitch
        }
    }

    func calibrate() {
        referenceAttitude = motionManager.deviceMotion?.attitude
    }

    // Normalized values for BLE packet
    var normalizedSteer: Int8 {
        let scaled = max(-1.0, min(1.0, roll / (.pi / 2))) // -1 to +1 range
        return Int8(scaled * 127)
    }

    var normalizedThrottle: UInt8 {
        let forward = max(0.0, -pitch) // negative pitch = forward
        let scaled = min(forward / (.pi / 4), 1.0)
        return UInt8(scaled * 255)
    }

    var normalizedBrake: UInt8 {
        let backward = max(0.0, pitch) // positive pitch = backward
        let scaled = min(backward / (.pi / 4), 1.0)
        return UInt8(scaled * 255)
    }
}
