//
//  ContentView.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//

import SwiftUI

//struct ContentView: View {
//    @StateObject var bleManager = BLEManager()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(bleManager.isConnected ? "🟢 Connected to iPhone" : "🔴 Not Connected")
//                .font(.headline)
//                .foregroundColor(bleManager.isConnected ? .green : .red)
//
//            Divider()
//
//            Text("🛞 Steer: \(bleManager.steer)")
//            Text("⚡️ Throttle: \(bleManager.throttle)")
//            Text("🛑 Brake: \(bleManager.brake)")
//            Text("🔘 Buttons: \(bleManager.buttons)")
//        }
//        .padding()
//    }
//}


struct ContentView: View {
    // You could use a temporary manager here for testing
    let testGamepadManager = VirtualGamepadManager()
    @State private var steerValue: Double = 0.0

    var body: some View {
        VStack(spacing: 20) {
            Text("Virtual Gamepad Test")
            
            Button("Activate Gamepad") {
                Task {
                    await testGamepadManager.activate()
                }
            }
            
            Slider(value: $steerValue, in: -127...127)
                .padding()
            
            Button("Deactivate Gamepad") {
                testGamepadManager.deactivate()
            }
        }
        .padding()
        .onChange(of: steerValue) { newValue in
            Task {
                // Send a report with the slider value for steer, and default values for others
                await testGamepadManager.sendReport(
                    steer: Int8(newValue),
                    throttle: 100, // some test value
                    brake: 0,
                    buttons: 1 // press button 1
                )
            }
        }
    }
}
