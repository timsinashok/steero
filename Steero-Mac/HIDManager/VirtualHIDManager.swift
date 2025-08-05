//
//  VirtualHIDManager.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/3/25.
//

import Foundation
import IOKit.hid
import IOKit

final class VirtualHIDManager {
    static let shared = VirtualHIDManager()

    private var device: IOHIDUserDevice?

    private init() {
        setupDevice()
    }

    private func setupDevice() {
        // HID descriptor for: steering (X), throttle (Y), brake (Z), 2 buttons
        let descriptor: [UInt8] = [
            0x05, 0x01,       // Usage Page (Generic Desktop)
            0x09, 0x04,       // Usage (Joystick)
            0xA1, 0x01,       // Collection (Application)

              // Steering (X) - signed 16-bit
              0x05, 0x01,     //   Usage Page (Generic Desktop)
              0x09, 0x30,     //   Usage (X)
              0x15, 0x80,     //   Logical Minimum (-128) -- we'll scale into this
              0x25, 0x7F,     //   Logical Maximum (127)
              0x75, 0x08,     //   Report Size (8)
              0x95, 0x01,     //   Report Count (1)
              0x81, 0x02,     //   Input (Data, Variable, Absolute)

              // Throttle (Y) - unsigned 8-bit
              0x09, 0x31,     //   Usage (Y)
              0x15, 0x00,     //   Logical Minimum (0)
              0x25, 0xFF,     //   Logical Maximum (255)
              0x75, 0x08,     //   Report Size (8)
              0x95, 0x01,     //   Report Count (1)
              0x81, 0x02,     //   Input (Data, Variable, Absolute)

              // Brake (Z) - unsigned 8-bit
              0x09, 0x32,     //   Usage (Z)
              0x15, 0x00,
              0x25, 0x7F,     // range 0..127
              0x75, 0x08,
              0x95, 0x01,
              0x81, 0x02,

              // Buttons (2)
              0x05, 0x09,     //   Usage Page (Button)
              0x19, 0x01,     //   Usage Minimum (Button 1)
              0x29, 0x02,     //   Usage Maximum (Button 2)
              0x15, 0x00,     //   Logical Min (0)
              0x25, 0x01,     //   Logical Max (1)
              0x75, 0x01,     //   Report Size (1)
              0x95, 0x02,     //   Report Count (2)
              0x81, 0x02,     //   Input (Data, Variable, Absolute)

              // Padding to byte align (2 bits)
              0x75, 0x01,     //   Report Size (1)
              0x95, 0x02,     //   Report Count (2)
              0x81, 0x03,     //   Input (Constant, Variable, Absolute) -- padding

            0xC0              // End Collection
        ]

        let properties: [String: Any] = [
            kIOHIDReportDescriptorKey as String: Data(descriptor),
            kIOHIDVendorIDKey as String: 0x1234,
            kIOHIDProductIDKey as String: 0x5678,
            kIOHIDManufacturerKey as String: "Steero",
            kIOHIDProductKey as String: "Virtual Wheel",
            kIOHIDVersionNumberKey as String: 1
        ]

        device = IOHIDUserDeviceCreateWithProperties(kCFAllocatorDefault, properties as CFDictionary)
        if device == nil {
            print("❌ Failed to create virtual HID device")
        } else {
            print("✅ Virtual HID device created")
        }
    }

    /// Report format: [steer (Int8), throttle (UInt8), brake (UInt8), buttons bitfield (lower 2 bits), padding nibble]
    func sendReport(steer: Int8, throttle: UInt8, brake: UInt8, buttons: UInt8) {
        guard let device = device else { return }

        // Buttons: only lower 2 bits used
        let buttonBits = buttons & 0b11

        var report: [UInt8] = [
            UInt8(bitPattern: steer),   // steering signed
            throttle,                  // throttle
            brake,                     // brake
            buttonBits                // buttons + will be padded implicitly
        ]

        // Because of the descriptor, we have total bits:
        // steer(8) + throttle(8) + brake(8) + buttons(2) + padding(2) = 28 bits -> 4 bytes when packed.
        // Here we send 4 bytes; the last byte includes buttons in its lower bits, rest is padding.
        let reportData = Data(report)
        let result = IOHIDUserDeviceHandleReport(device, [UInt8](reportData), reportData.count)
        if result != kIOReturnSuccess {
            print("⚠️ Failed to send HID report: \(result)")
        }
    }
}
