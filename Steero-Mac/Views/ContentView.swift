//
//  ContentView.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var ble = BLEManager()

    var body: some View {
        Text("Waiting for BLE packets...")
            .padding()
    }
}

