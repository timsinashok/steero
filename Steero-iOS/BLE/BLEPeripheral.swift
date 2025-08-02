//
//  BLEPeripheral.swift
//  Steero-iOS
//
//  Created by Ashok Timsina on 8/2/25.
//

import Foundation
import CoreBluetooth

class BLEPeripheral: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var characteristic: CBMutableCharacteristic?
    private var isReady = false

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else {
            print("BLE not available")
            return
        }

        let serviceUUID = CBUUID(string: "FFF0")
        let charUUID = CBUUID(string: "FFF1")

        let char = CBMutableCharacteristic(
            type: charUUID,
            properties: [.notify],
            value: nil,
            permissions: [.readable]
        )

        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [char]

        peripheralManager.add(service)
        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "SteeroWheel",
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
        ])

        self.characteristic = char
        self.isReady = true
        print("BLE advertising as SteeroWheel")
    }

    func send(data: Data) {
        guard let char = characteristic, isReady else { return }
        peripheralManager.updateValue(data, for: char, onSubscribedCentrals: nil)
    }
}
