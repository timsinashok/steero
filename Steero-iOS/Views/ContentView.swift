//
//  ContentView.swift
//  Steero-iOS
//
//  Created by Ashok Timsina on 8/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var motion = MotionManager()
    @StateObject private var ble = BLEPeripheral()

    @State private var handbrake = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Steering: \(motion.normalizedSteer)")
            Text("Throttle: \(motion.normalizedThrottle)")
            Text("Brake: \(motion.normalizedBrake)")

            Toggle("Handbrake", isOn: $handbrake)
                .toggleStyle(SwitchToggleStyle())
                .padding()

            Button("Calibrate") {
                motion.calibrate()
            }
            .buttonStyle(.borderedProminent)

            Text("Broadcasting via BLE…")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .onAppear {
            motion.startUpdates()
            startSendingPackets()
        }
    }

    func startSendingPackets() {
        Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            let packet = ControlPacket(
                steer: motion.normalizedSteer,
                throttle: motion.normalizedThrottle,
                brake: motion.normalizedBrake,
                buttons: handbrake ? 0b00000001 : 0
            )
            ble.send(data: packet.toData())
        }
    }
}
