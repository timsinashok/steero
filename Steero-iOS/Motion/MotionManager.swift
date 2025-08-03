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
    @Published var yaw: Double = 0

    func startUpdates() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let attitude = motion?.attitude else { return }

            if let reference = self.referenceAttitude {
                attitude.multiply(byInverseOf: reference)
            }

            self.roll = attitude.roll
            self.pitch = attitude.pitch
            self.yaw = attitude.yaw
        }
    }

    func calibrate() {
        referenceAttitude = motionManager.deviceMotion?.attitude
    }

    /// Map roll (-π/2 to +π/2) to steering [-127, 127]
    var normalizedSteer: Int8 {
        let scaled = max(-1.0, min(1.0, yaw / (.pi / 2)))
        return Int8(scaled * 127)
    }

    /// Map pitch (-π/4 forward to 0 flat) to throttle [0, 255]
    var normalizedThrottle: Int8 {
        let forward = max(0.0, roll) // Negative pitch = forward
        let scaled = min(forward / (.pi / 4), 1.0)
        return Int8(scaled * 255)
    }
}
