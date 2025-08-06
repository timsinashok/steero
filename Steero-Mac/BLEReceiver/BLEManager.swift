//////
//////  BLEManager.swift
//////  Steero-Mac
//////
//////  Created by Ashok Timsina on 8/2/25.
//////
////
////import Foundation
////import CoreBluetooth
////import Combine
////
////class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
////    private var centralManager: CBCentralManager!
////    private var discoveredPeripheral: CBPeripheral?
////    private var controlCharacteristic: CBCharacteristic?
////
////    private let serviceUUID = CBUUID(string: "FFF0")
////    private let characteristicUUID = CBUUID(string: "FFF1")
////
////    @Published var isConnected = false
////    @Published var steer: Int8 = 0
////    @Published var throttle: UInt8 = 0
////    @Published var brake: UInt8 = 0
////    @Published var buttons: UInt8 = 0
////
////    override init() {
////        super.init()
////        centralManager = CBCentralManager(delegate: self, queue: nil)
////    }
////    func centralManagerDidUpdateState(_ central: CBCentralManager) {
////        switch central.state {
////        case .unknown:
////            print("Bluetooth state: unknown")
////        case .resetting:
////            print("Bluetooth state: resetting")
////        case .unsupported:
////            print("Bluetooth state: unsupported")
////        case .unauthorized:
////            print("Bluetooth state: unauthorized")
////        case .poweredOff:
////            print("Bluetooth state: powered off")
////        case .poweredOn:
////            print("Bluetooth state: powered on")
////            print("🔍 Scanning for peripherals with service \(serviceUUID)")
////            isConnected = false
////            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
////        @unknown default:
////            print("Bluetooth state: unknown default")
////        }
////    }
////
////    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
////        print("📡 Found peripheral: \(peripheral.name ?? "Unknown")")
////
////        // Save reference and connect
////        centralManager.stopScan()
////        discoveredPeripheral = peripheral
////        peripheral.delegate = self
////        centralManager.connect(peripheral, options: nil)
////    }
////
////    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
////        print("✅ Connected to peripheral")
////        isConnected = true
////        peripheral.discoverServices([serviceUUID])
////    }
////
////    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
////        print("❌ Disconnected from peripheral")
////        isConnected = false
////        discoveredPeripheral = nil
////        controlCharacteristic = nil
////
////        // Optional: Reconnect
////        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
////    }
////
////    // MARK: - CBPeripheralDelegate
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
////
////        for char in characteristics where char.uuid == characteristicUUID {
////            controlCharacteristic = char
////            peripheral.setNotifyValue(true, for: char)
////            print("🔔 Subscribed to characteristic notifications")
////        }
////    }
////
////    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
////            guard let data = characteristic.value else { return }
////
////            // Expected format: 4 bytes [Int8 steer, Int8 throttle, UInt8 brake, UInt8 buttons]
////            if data.count >= 4 {
////                steer = Int8(bitPattern: data[0])
////                throttle = data[1]
////                brake = data[2]
////                buttons = data[3]
////
////                print("📥 Received: steer=\(steer), throttle=\(throttle), brake=\(brake), buttons=\(buttons)")
////                print("Executing the received signal...")
////                KeyInputManager.process(steer: steer, throttle: throttle, brake: brake)
////            }
////        }
////}
//
//
//
//// BLEManager.swift (modified)
//
//import Foundation
//import CoreBluetooth
//import Combine
//
//class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
//    // ... existing properties
//    private let hidManager = HIDDeviceManager()
//    
//    // ... existing init()
//
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("✅ Connected to peripheral")
//        isConnected = true
//        hidManager.createDevice() // Create the HID device here!
//        peripheral.discoverServices([serviceUUID])
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        print("❌ Disconnected from peripheral")
//        isConnected = false
//        hidManager.destroyDevice() // Destroy the HID device here!
//        discoveredPeripheral = nil
//        controlCharacteristic = nil
//        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
//    }
//
//    // ... existing CBPeripheralDelegate methods
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        guard let data = characteristic.value else { return }
//
//        // Expected format: 4 bytes [Int8 steer, Int8 throttle, UInt8 brake, UInt8 buttons]
//        if data.count >= 4 {
//            steer = Int8(bitPattern: data[0])
//            throttle = data[1]
//            brake = data[2]
//            buttons = data[3]
//            
//            // This is the key change: send the report to the HID device.
//            hidManager.sendReport(steer: steer, throttle: throttle, brake: brake, buttons: buttons)
//
//            print("📥 Received: steer=\(steer), throttle=\(throttle), brake=\(brake), buttons=\(buttons)")
//        }
//    }
//}


//
//  BLEManager.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//

import Foundation
import CoreBluetooth
import Combine
import OSLog

private let logger = Logger(subsystem: "com.yourcompany.Steero-Mac", category: "BLEManager")

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var controlCharacteristic: CBCharacteristic?

    private let serviceUUID = CBUUID(string: "FFF0")
    private let characteristicUUID = CBUUID(string: "FFF1")
    
    private let hidManager = HIDDeviceManager()

    @Published var isConnected = false
    @Published var steer: Int8 = 0
    @Published var throttle: UInt8 = 0
    @Published var brake: UInt8 = 0
    @Published var buttons: UInt8 = 0

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            logger.info("Bluetooth state: unknown")
        case .resetting:
            logger.info("Bluetooth state: resetting")
        case .unsupported:
            logger.info("Bluetooth state: unsupported")
        case .unauthorized:
            logger.info("Bluetooth state: unauthorized")
        case .poweredOff:
            logger.info("Bluetooth state: powered off")
        case .poweredOn:
            logger.info("Bluetooth state: powered on")
            logger.info("🔍 Scanning for peripherals with service \(self.serviceUUID)")
            self.isConnected = false
            self.centralManager.scanForPeripherals(withServices: [self.serviceUUID], options: nil)
        @unknown default:
            logger.info("Bluetooth state: unknown default")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        logger.info("📡 Found peripheral: \(peripheral.name ?? "Unknown")")

        // Save reference and connect
        centralManager.stopScan()
        discoveredPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("✅ Connected to peripheral")
        isConnected = true
        hidManager.createDevice() // Create the HID device upon successful BLE connection
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.info("❌ Disconnected from peripheral")
        isConnected = false
        hidManager.destroyDevice() // Destroy the HID device when disconnected
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
            logger.info("🔔 Subscribed to characteristic notifications")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }

        // Expected format: 4 bytes [Int8 steer, UInt8 throttle, UInt8 brake, UInt8 buttons]
        if data.count >= 4 {
            steer = Int8(bitPattern: data[0])
            throttle = data[1]
            brake = data[2]
            buttons = data[3]
            
            // This is the key change: send the report to the virtual HID device.
            hidManager.sendReport(steer: steer, throttle: throttle, brake: brake, buttons: buttons)

            logger.debug("📥 Received: steer=\(self.steer), throttle=\(self.throttle), brake=\(self.brake), buttons=\(self.buttons)")
        }
    }
}
