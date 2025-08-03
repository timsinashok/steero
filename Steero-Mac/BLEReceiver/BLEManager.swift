//////
//////  BLEManager.swift
//////  Steero-Mac
//////
//////  Created by Ashok Timsina on 8/2/25.
//////
////
////import Foundation
////import CoreBluetooth
////
////class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
////    private var centralManager: CBCentralManager!
////    private var connectedPeripheral: CBPeripheral?
////    private var dataCharacteristic: CBCharacteristic?
////
////    let serviceUUID = CBUUID(string: "FFF0")      // same as iPhone's
////    let characteristicUUID = CBUUID(string: "FFF1")  // match iPhone
////
////    override init() {
////        super.init()
////        centralManager = CBCentralManager(delegate: self, queue: nil)
////    }
////
////    func centralManagerDidUpdateState(_ central: CBCentralManager) {
////        if central.state == .poweredOn {
////            print("Scanning for RevoraWheel...")
////            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
////        } else {
////            print("Bluetooth not available on Mac")
////        }
////    }
////
////    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
////                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
////        print("Found peripheral: \(peripheral.name ?? "Unknown")")
////        connectedPeripheral = peripheral
////        peripheral.delegate = self
////        centralManager.stopScan()
////        centralManager.connect(peripheral, options: nil)
////    }
////
////    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
////        print("Connected to \(peripheral.name ?? "Unknown")")
////        peripheral.discoverServices([serviceUUID])
////    }
////
////    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
////        guard let services = peripheral.services else { return }
////        for service in services where service.uuid == serviceUUID {
////            peripheral.discoverCharacteristics([characteristicUUID], for: service)
////        }
////    }
////
////    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
////        guard let characteristics = service.characteristics else { return }
////        for char in characteristics where char.uuid == characteristicUUID {
////            dataCharacteristic = char
////            peripheral.setNotifyValue(true, for: char)
////            print("Subscribed to data characteristic")
////        }
////    }
////
////    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
////        guard let data = characteristic.value else { return }
////        decodePacket(data)
////    }
////
////    func decodePacket(_ data: Data) {
////        guard data.count >= 4 else { return }
////
////        let steer = Int8(bitPattern: data[0])
////        let throttle = data[1]
////        let brake = data[2]
////        let buttons = data[3]
////
////        print("Steer: \(steer), Throttle: \(throttle), Brake: \(brake), Buttons: \(buttons)")
////    }
////}
//
//
//import Foundation
//import CoreBluetooth
//import Combine
//
//class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
//    private var centralManager: CBCentralManager!
//    private var peripheral: CBPeripheral?
//    
//    // Replace with the UUIDs used in your iOS BLE peripheral
//    private let serviceUUID = CBUUID(string: "FFF0")
//    private let characteristicUUID = CBUUID(string: "FFF1")
//    
//    @Published var steer: Int8 = 0
//    @Published var throttle: UInt8 = 0
//    @Published var brake: UInt8 = 0
//    @Published var buttons: UInt8 = 0
//    
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//
//    // MARK: - CBCentralManagerDelegate
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            print("🔍 Scanning for peripherals...")
//            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
//        } else {
//            print("⚠️ Bluetooth not available: \(central.state.rawValue)")
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
//                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("✅ Found peripheral: \(peripheral.name ?? "Unknown")")
//        self.peripheral = peripheral
//        self.peripheral?.delegate = self
//        centralManager.stopScan()
//        centralManager.connect(peripheral, options: nil)
//    }
//
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("🔗 Connected to peripheral")
//        peripheral.discoverServices([serviceUUID])
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else { return }
//        for service in services {
//            if service.uuid == serviceUUID {
//                print("📡 Service found")
//                peripheral.discoverCharacteristics([characteristicUUID], for: service)
//            }
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else { return }
//        for characteristic in characteristics {
//            if characteristic.uuid == characteristicUUID {
//                print("📥 Subscribing to characteristic")
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        guard let data = characteristic.value else {
//            print("⚠️ Received nil data")
//            return
//        }
//
//        guard data.count >= 4 else {
//            print("⚠️ Received short data: \(data.count) bytes")
//            return
//        }
//
//        let receivedSteer = Int8(bitPattern: data[0])
//        let receivedThrottle = data[1]
//        let receivedBrake = data[2]
//        let receivedButtons = data[3]
//
//        DispatchQueue.main.async {
//            self.steer = receivedSteer
//            self.throttle = receivedThrottle
//            self.brake = receivedBrake
//            self.buttons = receivedButtons
//
//            print("🎮 steer: \(receivedSteer), throttle: \(receivedThrottle), brake: \(receivedBrake), buttons: \(receivedButtons)")
//        }
//    }
//}


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


//    // MARK: - CBCentralManagerDelegate
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            print("🔍 Scanning for peripherals with service \(serviceUUID)")
//            isConnected = false
//            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
//        } else {
//            print("⚠️ Bluetooth not available: \(central.state.rawValue)")
//            isConnected = false
//        }
//    }

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
            KeyInputManager.process(steer: steer, throttle: throttle)
        }
    }
}
