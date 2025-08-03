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
    @State private var brake = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Steering: \(motion.normalizedSteer)")
            Text("Throttle: \(motion.normalizedThrottle)")
            Text("Brake: \(brake ? 255 : 0)")

            Toggle("Handbrake", isOn: $handbrake)
                .toggleStyle(SwitchToggleStyle())
                .padding(.horizontal)

            Toggle("Brake", isOn: $brake)
                .toggleStyle(SwitchToggleStyle())
                .padding(.horizontal)

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
            let packet = ControlPacket.make(
                steer: motion.normalizedSteer,
                throttle: motion.normalizedThrottle,
                handbrake: handbrake,
                brake: brake
            )
            ble.send(data: packet.toData())
        }
    }
}
