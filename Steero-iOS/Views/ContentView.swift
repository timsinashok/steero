////
////  ContentView.swift
////  Steero-iOS
////
////  Created by Ashok Timsina on 8/2/25.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var motion = MotionManager()
//    @StateObject private var ble = BLEPeripheral()
//
//    @State private var handbrake = false
//    @State private var brake = false
//
//    var body: some View {
//        VStack(spacing: 24) {
//            Text("Steering: \(motion.normalizedSteer)")
//            Text("Throttle: \(motion.normalizedThrottle)")
//            Text("Brake: \(brake ? 255 : 0)")
//
//            Toggle("Handbrake", isOn: $handbrake)
//                .toggleStyle(SwitchToggleStyle())
//                .padding(.horizontal)
//
//            Toggle("Brake", isOn: $brake)
//                .toggleStyle(SwitchToggleStyle())
//                .padding(.horizontal)
//
//            Button("Calibrate") {
//                motion.calibrate()
//            }
//            .buttonStyle(.borderedProminent)
//
//            Text("Broadcasting via BLE…")
//                .font(.footnote)
//                .foregroundStyle(.secondary)
//        }
//        .padding()
//        .onAppear {
//            motion.startUpdates()
//            startSendingPackets()
//        }
//    }
//
//    func startSendingPackets() {
//        Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
//            let packet = ControlPacket.make(
//                steer: motion.normalizedSteer,
//                throttle: motion.normalizedThrottle,
//                handbrake: handbrake,
//                brake: brake
//            )
//            ble.send(data: packet.toData())
//        }
//    }
//}


import SwiftUI

struct ContentView: View {
    @StateObject private var motion = MotionManager()
    @StateObject private var ble = BLEPeripheral()

    @State private var handbrake = false
    @State private var brakeValue: UInt8 = 0

    // Configuration: time to reach max brake (in seconds)
    let rampDuration: TimeInterval = 1.0

    // Internal timer/tracking
    @State private var holdStart: Date?
    @State private var rampTimer: Timer?

    var body: some View {
        VStack(spacing: 24) {
            Text("Steering: \(motion.normalizedSteer)")
            Text("Throttle: \(motion.normalizedThrottle)")
            Text("Brake Value: \(brakeValue)")

            Toggle("Handbrake", isOn: $handbrake)
                .toggleStyle(SwitchToggleStyle())
                .padding(.horizontal)

            HStack {
                Spacer() // push button to the right
                HoldBrakeButton(
                    brakeValue: $brakeValue,
                    rampDuration: rampDuration
                )
                .frame(width: 100, height: 50)
            }
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
                brakeValue: brakeValue
            )
            ble.send(data: packet.toData())
        }
    }
}

struct HoldBrakeButton: View {
    @Binding var brakeValue: UInt8
    let rampDuration: TimeInterval

    // internal state
    @State private var timer: Timer?
    @State private var startTime: Date?

    var body: some View {
        Text("Brake")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 2)
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if startTime == nil {
                            startTime = Date()
                            startRamp()
                        }
                    }
                    .onEnded { _ in
                        stopRamp()
                    }
            )
    }

    private func startRamp() {
        // invalidate existing just in case
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            guard let start = startTime else { return }
            let elapsed = Date().timeIntervalSince(start)
            let fraction = min(1.0, elapsed / rampDuration)
            let scaled = UInt8(round(fraction * 127.0))
            brakeValue = scaled
        }
    }

    private func stopRamp() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        // reset to zero on release:
        brakeValue = 0
    }
}
