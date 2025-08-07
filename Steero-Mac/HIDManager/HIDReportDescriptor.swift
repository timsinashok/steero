////
////  HIDReportDescriptor.swift
////  Steero-Mac
////
////  Created by Ashok Timsina on 8/5/25.
////
//
import Foundation

let racingWheelReportDescriptor: [UInt8] = [
    0x05, 0x02,                    // USAGE_PAGE (Simulation Controls)
    0x09, 0xBA,                    // USAGE (Steering)
    0xA1, 0x01,                    // COLLECTION (Application)

    // Steering axis
    0x15, 0x81,                    //   LOGICAL_MINIMUM (-127)
    0x25, 0x7F,                    //   LOGICAL_MAXIMUM (127)
    0x75, 0x08,                    //   REPORT_SIZE (8)
    0x95, 0x01,                    //   REPORT_COUNT (1)
    0x09, 0xBA,                    //   USAGE (Steering)
    0x81, 0x02,                    //   INPUT (Data,Var,Abs)

    // Acceleration axis (Throttle)
    0x09, 0xC4,                    //   USAGE (Accelerator)
    0x81, 0x02,                    //   INPUT (Data,Var,Abs)

    // Brake axis
    0x09, 0xC5,                    //   USAGE (Brake)
    0x81, 0x02,                    //   INPUT (Data,Var,Abs)

    // Buttons (8)
    0x05, 0x09,                    //   USAGE_PAGE (Button)
    0x19, 0x01,                    //   USAGE_MINIMUM (Button 1)
    0x29, 0x08,                    //   USAGE_MAXIMUM (Button 8)
    0x15, 0x00,                    //   LOGICAL_MINIMUM (0)
    0x25, 0x01,                    //   LOGICAL_MAXIMUM (1)
    0x75, 0x01,                    //   REPORT_SIZE (1)
    0x95, 0x08,                    //   REPORT_COUNT (8)
    0x81, 0x02,                    //   INPUT (Data,Var,Abs)

    0xC0                           // END_COLLECTION
]
//
//  HIDReportDescriptor.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/5/25.
//

import Foundation

// A standard Gamepad report descriptor.
// This is more likely to be recognized by generic tools and games.
// Report Format: [X-Axis (Int8), Y-Axis (Int8), Z-Axis (Int8), Buttons (UInt8)]
// Total size: 4 bytes
let gamepadReportDescriptor: [UInt8] = [
    0x05, 0x01,        // USAGE_PAGE (Generic Desktop)
    0x09, 0x05,        // USAGE (Game Pad)
    0xA1, 0x01,        // COLLECTION (Application)
    
    // 8 Buttons
    0x05, 0x09,        //   USAGE_PAGE (Button)
    0x19, 0x01,        //   USAGE_MINIMUM (Button 1)
    0x29, 0x08,        //   USAGE_MAXIMUM (Button 8)
    0x15, 0x00,        //   LOGICAL_MINIMUM (0)
    0x25, 0x01,        //   LOGICAL_MAXIMUM (1)
    0x75, 0x01,        //   REPORT_SIZE (1)
    0x95, 0x08,        //   REPORT_COUNT (8)
    0x81, 0x02,        //   INPUT (Data,Var,Abs)
    
    // 3 Axes (X, Y, Z) for Steering, Throttle, Brake
    0x05, 0x01,        //   USAGE_PAGE (Generic Desktop)
    0x09, 0x30,        //   USAGE (X)
    0x09, 0x31,        //   USAGE (Y)
    0x09, 0x32,        //   USAGE (Z)
    0x15, 0x81,        //   LOGICAL_MINIMUM (-127)
    0x25, 0x7F,        //   LOGICAL_MAXIMUM (127)
    0x75, 0x08,        //   REPORT_SIZE (8)
    0x95, 0x03,        //   REPORT_COUNT (3)
    0x81, 0x02,        //   INPUT (Data,Var,Abs)
    
    0xC0               // END_COLLECTION
]
