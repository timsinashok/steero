//
//  BLEManager.swift
//  Steero-Mac
//
//  Created by Ashok Timsina on 8/2/25.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataCharacteristic: CBCharacteristic?

    let serviceUUID = CBUUID(string: "YOUR_SERVICE_UUID")      // same as iPhone's
    let characteristicUUID = CBUUID(string: "YOUR_CHARACTERISTIC_UUID")  // match iPhone

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Scanning for RevoraWheel...")
            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            print("Bluetooth not available on Mac")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found peripheral: \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices([serviceUUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for char in characteristics where char.uuid == characteristicUUID {
            dataCharacteristic = char
            peripheral.setNotifyValue(true, for: char)
            print("Subscribed to data characteristic")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        decodePacket(data)
    }

    func decodePacket(_ data: Data) {
        guard data.count >= 4 else { return }

        let steer = Int8(bitPattern: data[0])
        let throttle = data[1]
        let brake = data[2]
        let buttons = data[3]

        print("Steer: \(steer), Throttle: \(throttle), Brake: \(brake), Buttons: \(buttons)")
    }
}
