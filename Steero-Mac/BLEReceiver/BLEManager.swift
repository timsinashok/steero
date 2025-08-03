//
//  BLEManager.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//

import Foundation
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var controlCharacteristic: CBCharacteristic?

    private let serviceUUID = CBUUID(string: "FFF0")
    private let characteristicUUID = CBUUID(string: "FFF1")

    @Published var isConnected = false
    @Published var steer: Int8 = 0
    @Published var throttle: UInt8 = 0
    @Published var brake: UInt8 = 0
    @Published var buttons: UInt8 = 0

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth state: unknown")
        case .resetting:
            print("Bluetooth state: resetting")
        case .unsupported:
            print("Bluetooth state: unsupported")
        case .unauthorized:
            print("Bluetooth state: unauthorized")
        case .poweredOff:
            print("Bluetooth state: powered off")
        case .poweredOn:
            print("Bluetooth state: powered on")
            print("🔍 Scanning for peripherals with service \(serviceUUID)")
            isConnected = false
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        @unknown default:
            print("Bluetooth state: unknown default")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("📡 Found peripheral: \(peripheral.name ?? "Unknown")")

        // Save reference and connect
        centralManager.stopScan()
        discoveredPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to peripheral")
        isConnected = true
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("❌ Disconnected from peripheral")
        isConnected = false
        discoveredPeripheral = nil
        controlCharacteristic = nil

        // Optional: Reconnect
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for char in characteristics where char.uuid == characteristicUUID {
            controlCharacteristic = char
            peripheral.setNotifyValue(true, for: char)
            print("🔔 Subscribed to characteristic notifications")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }

        // Expected format: 5 bytes [Int8, UInt8, UInt8, UInt8, UInt8]
        if data.count >= 4 {
            steer = Int8(bitPattern: data[0])
            throttle = data[1]
            brake = data[2]
            buttons = data[3]

            print("📥 Received: steer=\(steer), throttle=\(throttle), brake=\(brake), buttons=\(buttons)")
            print("Executing the received signal...")
            KeyInputManager.process(steer: steer, throttle: throttle)
        }
    }
}
