//
//  ContentView.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bleManager = BLEManager()

    var body: some View {
        VStack(spacing: 20) {
            Text(bleManager.isConnected ? "🟢 Connected to iPhone" : "🔴 Not Connected")
                .font(.headline)
                .foregroundColor(bleManager.isConnected ? .green : .red)

            Divider()

            Text("🛞 Steer: \(bleManager.steer)")
            Text("⚡️ Throttle: \(bleManager.throttle)")
            Text("🛑 Brake: \(bleManager.brake)")
            Text("🔘 Buttons: \(bleManager.buttons)")
        }
        .padding()
    }
}
