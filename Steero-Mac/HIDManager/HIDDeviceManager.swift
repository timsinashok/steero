////
////  HIDDeviceManager.swift
////  Steero-Mac
////
////  Created by Ashok Timsina on 8/5/25.
////
//
//import Foundation
//import IOKit.hid
//import OSLog
//
//private let logger = Logger(subsystem: "com.yourcompany.Steero-Mac", category: "HIDDeviceManager")
//
//class HIDDeviceManager {
//    private var device: IOHIDUserDevice?
//    private var isCreated: Bool = false
//
//    func createDevice() {
//        guard !isCreated else {
//            logger.info("Device already created.")
//            return
//        }
//
//        let properties: [String: Any] = [
//            kIOHIDPrimaryUsageKey: kHIDUsage_GD_GamePad,
//            kIOHIDPrimaryUsagePageKey: kHIDPage_GenericDesktop,
//            kIOHIDPhysicalDeviceUniqueIDKey: "com.yourcompany.SteeroWheel", // Unique ID
//            kIOHIDProductKey: "Steero Virtual Wheel"
//        ]
//
//        device = IOHIDUserDeviceCreate(kCFAllocatorDefault,
//                                       gamingDeviceReportDescriptor as CFData,
//                                       properties as CFDictionary)
//        
//        if device != nil {
//            isCreated = true
//            logger.info("✅ Virtual HID device created successfully.")
//        } else {
//            logger.error("❌ Failed to create virtual HID device.")
//        }
//    }
//
//    func destroyDevice() {
//        if let device = device {
//            // IOHIDUserDevice doesn't have a direct "destroy" function,
//            // but releasing the CF reference is enough.
//            CFRelease(device)
//            self.device = nil
//            self.isCreated = false
//            logger.info("❌ Virtual HID device destroyed.")
//        }
//    }
//
//    // Function to construct and send the HID report
//    func sendReport(steer: Int8, throttle: UInt8, brake: UInt8, buttons: UInt8) {
//        guard isCreated, let device = device else {
//            logger.debug("Device not created, skipping report.")
//            return
//        }
//
//        // The report needs to be a single byte array matching the descriptor
//        // Steering (Int8) -> 1 byte
//        // Throttle/Brake (combined in this example) -> 1 byte
//        // Buttons (8 bits) -> 1 byte
//        // Total: 3 bytes
//        
//        // We'll map throttle to positive values of the Y-axis and brake to negative
//        var yAxisValue: Int8 = 0
//        if throttle > 0 {
//            yAxisValue = Int8(clamping: Int(throttle)) // Assuming throttle is 0-127
//        } else if brake > 0 {
//            yAxisValue = -Int8(clamping: Int(brake)) // Assuming brake is 0-127
//        }
//        
//        let reportData = Data([
//            UInt8(bitPattern: steer),
//            UInt8(bitPattern: yAxisValue),
//            buttons
//        ])
//        
//        let result = IOHIDUserDeviceSetReport(device,
//                                              kIOHIDReportTypeInput,
//                                              0, // Report ID (0 if not used)
//                                              reportData as CFData,
//                                              reportData.count)
//
//        if result != kIOReturnSuccess {
//            logger.error("❌ Failed to send HID report: \(result)")
//        } else {
//            logger.debug("✅ Sent HID report: steer=\(steer), throttle=\(throttle), brake=\(brake)")
//        }
//    }
//}

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
    
    // HIDDeviceManager.swift (updated sendReport function)
    
    //    func sendReport(steer: Int8, throttle: UInt8, brake: UInt8, buttons: UInt8) {
    //        guard isCreated, let device = device else {
    //            logger.debug("Device not created, skipping report.")
    //            return
    //        }
    //
    //        var yAxisValue: Int8 = 0
    //        if throttle > 0 {
    //            let scaledThrottle = (Double(throttle) / 255.0) * 127.0
    //            yAxisValue = Int8(clamping: Int(round(scaledThrottle)))
    //        } else if brake > 0 {
    //            yAxisValue = -Int8(clamping: Int(brake))
    //        }
    //
    //        // Construct the report data
    //        let reportData = Data([
    //            UInt8(bitPattern: steer),
    //            UInt8(bitPattern: yAxisValue),
    //            buttons
    //        ])
    //
    //        // Use the modern function you found in the documentation
    //        // This function also requires a timestamp
    //        let result = IOHIDUserDeviceHandleReportWithTimeStamp(device,
    //                                                              reportData as CFData,
    //                                                              0.0, // A ReportID of 0
    //                                                              CFAbsoluteTimeGetCurrent()) // Use the current time as the timestamp
    //
    //        if result != kIOReturnSuccess {
    //            logger.error("❌ Failed to send HID report with timestamp: \(result)")
    //        } else {
    //            logger.debug("✅ Sent HID report: steer=\(steer), yAxis=\(yAxisValue)")
    //        }
    //    }
    //}
    // HIDDeviceManager.swift (Corrected sendReport function)
    
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
