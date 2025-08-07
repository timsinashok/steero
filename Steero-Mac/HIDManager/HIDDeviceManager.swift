//
//  HIDDeviceManager.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//


import Foundation
import IOKit.hid
import OSLog
import IOKit
import IOKit.hid

private let logger = Logger(subsystem: "com.yourcompany.Steero-Mac", category: "HIDDeviceManager")

class HIDDeviceManager {
    private var device: IOHIDUserDevice?
    private var isCreated: Bool = false
    
    // HIDDeviceManager.swift (updated createDevice function)
    
    func createDevice() {
        logger.info("Attempting to create virtual HID device...")
        guard !isCreated else {
            logger.info("Device already created.")
            return
        }
        
        // Convert the Swift byte array to CFData
        let reportDescriptorData = Data(racingWheelReportDescriptor)
        
        // Create the properties dictionary, and now we add the report descriptor to it.
        let properties: [String: Any] = [
            kIOHIDPrimaryUsageKey: 0xBA, // Steering
            kIOHIDPrimaryUsagePageKey: 0x02, // Simulation Controls
            kIOHIDVendorIDKey: 0x046D, // Logitech (optional)
            kIOHIDProductIDKey: 0xC262, // G29 (optional)
            kIOHIDProductKey: "Steero Virtual Wheel",
            kIOHIDReportDescriptorKey: Data(racingWheelReportDescriptor)
        ]
        
        // Use the newer function.
        device = IOHIDUserDeviceCreateWithProperties(kCFAllocatorDefault,
                                                     properties as CFDictionary,
                                                     0) // options are typically 0 for this function
        
        if device != nil {
            isCreated = true
            logger.info("✅ Virtual HID device created successfully using IOHIDUserDeviceCreateWithProperties.")
        } else {
            logger.error("❌ Failed to create virtual HID device.")
        }
    }
    
    func destroyDevice() {
        if let device = device {
            // Fix: ARC now manages this object, we simply set the reference to nil.
            // CFRelease is no longer needed or available in Swift for this context.
            self.device = nil
            self.isCreated = false
            logger.info("❌ Virtual HID device destroyed.")
        }
    }
    
    
    func sendReport(steer: Int8, throttle: UInt8, brake: UInt8, buttons: UInt8) {
        guard isCreated, let device = device else {
            logger.debug("Device not created, skipping report.")
            return
        }
        
        // Map throttle to positive Y-axis and brake to negative Y-axis
        var yAxisValue: Int8 = 0
        if throttle > 0 {
            let scaledThrottle = (Double(throttle) / 255.0) * 127.0
            yAxisValue = Int8(clamping: Int(round(scaledThrottle)))
        } else if brake > 0 {
            yAxisValue = -Int8(clamping: Int(brake))
        }
        
        // The report data must be constructed in a byte array.
        let reportData = Data([
            UInt8(bitPattern: steer),
//            UInt8(bitPattern: throttle),
//            UInt8(bitPattern: brake),
            buttons
        ])

        
        // Convert the current time to a UInt64 timestamp
        let timestamp = UInt64(CFAbsoluteTimeGetCurrent() * 1_000_000_000)
        
        // The key change: use withUnsafeBytes to get a pointer to the report data
        reportData.withUnsafeBytes { rawBufferPointer in
            guard let reportPointer = rawBufferPointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                logger.error("❌ Failed to get a pointer to report data.")
                return
            }
            
            let result = IOHIDUserDeviceHandleReportWithTimeStamp(
                device,
                timestamp,
                reportPointer,
                reportData.count
            )
            
            if result != kIOReturnSuccess {
                logger.error("❌ Failed to send HID report with timestamp: \(result)")
            } else {
                logger.debug("✅ Sent HID report: steer=\(steer), yAxis=\(yAxisValue)")
            }
        }
    }
}
