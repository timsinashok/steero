//
//  ControlPacket.swift
//  Steero-iOS
//
//  Created by Ashok Timsina on 8/2/25.
//

import Foundation

struct ControlPacket {
    var steer: Int8            // -127...127
    var throttle: UInt8        // 0...255
    var brake: UInt8           // 0...255
    var buttons: UInt8         // bit 0 = handbrake, others free for future use

    func toData() -> Data {
        var buffer = [UInt8]()
        buffer.append(UInt8(bitPattern: steer))  // preserve signedness
        buffer.append(throttle)
        buffer.append(brake)
        buffer.append(buttons)
        return Data(buffer)
    }
}

