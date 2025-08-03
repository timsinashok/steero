//
//  ControlPacket.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//


import Foundation

struct ControlPacket {
    var steer: Int8
    var throttle: Int8
    var brake: UInt8
    var buttons: UInt8

    func toData() -> Data {
        var buffer = [UInt8]()
        buffer.append(UInt8(bitPattern: steer))
        buffer.append(UInt8(throttle))
        buffer.append(brake)
        buffer.append(buttons)
        return Data(buffer)
    }

    static func make(steer: Int8, throttle: Int8, handbrake: Bool, brake: Bool) -> ControlPacket {
        var flags: UInt8 = 0
        if handbrake { flags |= 0b00000001 }
        if brake     { flags |= 0b00000010 }

        return ControlPacket(
            steer: steer,
            throttle: throttle,
            brake: brake ? 255 : 0, // Full brake if pressed
            buttons: flags
        )
    }
}

