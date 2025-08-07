//
//  VirtualGamepadManager.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/5/25.
//

import Foundation
import CoreHID // <-- Import the new framework!
import OSLog
import AppKit // For SuspendingClock

// Make sure your project is configured for macOS 15.0+ to use this API.

private let logger = Logger(subsystem: "com.yourcompany.Steero-Mac", category: "VirtualGamepadManager")

// The delegate is required to handle requests from the system (e.g., get/set reports).
// For a simple output-only device, these can be minimal.
final class GamepadDelegate: HIDVirtualDeviceDelegate {
    
    // Handler for when the system wants to send data TO our virtual device.
    func hidVirtualDevice(_ device: HIDVirtualDevice, receivedSetReportRequestOfType type: HIDReportType, id: HIDReportID?, data: Data) throws {
        logger.info("Received Set Report Request") // (type: \(type.hashValue), id: \(id ?? 0))")
        // You could handle incoming data here if needed.
    }

    // Handler for when the system wants to get data FROM our virtual device.
    func hidVirtualDevice(_ device: HIDVirtualDevice, receivedGetReportRequestOfType type: HIDReportType, id: HIDReportID?, maxSize: size_t) throws -> Data {
        logger.info("Received Get Report Request") // (type: \(type.hashValue), id: \(id ?? 0))")
        // Return a default or current state report.
        // For now, an empty report is fine if not used.
        return Data()
    }
}


class VirtualGamepadManager {
    
    private var virtualDevice: HIDVirtualDevice?
    private let delegate = GamepadDelegate()
    
    func activate() async {
        guard virtualDevice == nil else {
            logger.info("Virtual gamepad already active.")
            return
        }
        
        logger.info("Attempting to create virtual gamepad...")
        
        let descriptor = Data(gamepadReportDescriptor)
        
        // Define the properties of our virtual device.
        let properties = HIDVirtualDevice.Properties(
            descriptor: descriptor,
            vendorID: 0x1A2B, // Custom Vendor ID
            productID: 0x3C4D, // Custom Product ID
            product: "Steero Virtual Gamepad",
            serialNumber: "STEERO-V1.0"
        )
        
        do {
            // Create the device
            let device = try HIDVirtualDevice(properties: properties)
            
            // Activate it with our delegate
            try await device?.activate(delegate: self.delegate)
            
            self.virtualDevice = device
            logger.info("✅ Virtual gamepad created and activated successfully.")
            
        } catch {
            logger.error("❌ Failed to create or activate virtual gamepad: \(error.localizedDescription)")
        }
    }
    
    func deactivate() {
        // Deactivating is as simple as releasing the reference.
        // The system will handle the removal of the device.
        if virtualDevice != nil {
            virtualDevice = nil
            logger.info("ℹ️ Virtual gamepad deactivated.")
        }
    }
    
    func sendReport(steer: Int8, throttle: UInt8, brake: UInt8, buttons: UInt8) async {
        guard let device = virtualDevice else {
            // logger.debug("Device not active, skipping report.") // This can be noisy
            return
        }
        
        // --- IMPORTANT ---
        // The report data MUST match the descriptor EXACTLY.
        // Our descriptor expects: [X-Axis, Y-Axis, Z-Axis, Buttons]
        
        // Let's map your inputs to our axes:
        // Steer -> X-Axis (already an Int8, perfect)
        // Throttle -> Y-Axis (needs to be mapped from 0-255 to -127-127, let's use 0-127 for simplicity)
        // Brake -> Z-Axis (needs to be mapped from 0-255 to -127-127, let's use 0-127 for simplicity)
        
        // Note: Many games expect throttle/brake on the same axis (e.g., Y+ and Y-).
        // For now, we'll keep them separate on Y and Z as per the descriptor.
        
        let yAxisValue = Int8(clamping: Int( (Double(throttle) / 255.0) * 127.0 ))
        let zAxisValue = Int8(clamping: Int( (Double(brake) / 255.0) * 127.0 ))
        
        let reportData = Data([
            UInt8(bitPattern: steer),      // X-Axis
            UInt8(bitPattern: yAxisValue), // Y-Axis
            UInt8(bitPattern: zAxisValue), // Z-Axis
            buttons                        // 8 Buttons
        ])
        
        do {
            try await device.dispatchInputReport(data: reportData, timestamp: SuspendingClock.now)
            // logger.debug("✅ Sent report: steer=\(steer), throttle=\(yAxisValue), brake=\(zAxisValue), buttons=\(String(buttons, radix: 2))")
        } catch {
            logger.error("❌ Failed to send HID report: \(error.localizedDescription)")
        }
    }
}
