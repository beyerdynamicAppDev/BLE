//
//  BluetoothManager.swift
//  BLE
//
//  Created by Maxim Schleicher on 16.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol BluetoothManagerDelegate {
    @objc optional func discoveredNewPeriphirals(periphiral:CBPeripheral)
    @objc optional func discoveredServices(services:[CBService])
    @objc optional func discoveredCharacteristics(characteristics:[CBCharacteristic])
}
class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    class var sharedInstance : BluetoothManager{
        struct Static{
            static let instance = BluetoothManager()
        }
        return Static.instance
    }
    
    let uuidDict:[String:String] = [
        "62644D69-6D69-5365-7276-696365000000" : "MIMI_SERVICE",
        "62644D69-6D69-5072-6F63-566572000000" : "MIMI_PROCESSING_VERSION",
        "62644D69-6D69-5072-6573-657400000000" : "MIMI_PRESET_ID",
        "62644D69-6D69-5573-6572-000000000000" : "MIMI_USER_ID",
        "62644D69-6D69-4870-5479-706500000000" : "MIMI_HEADPHONES_TYPE",
        "62644D69-6D69-5061-7261-6D7300000000" : "MIMI_DPS_PARAMS",
        "62644D69-6D69-4368-6563-6B73756D0000" : "MIMI_DSP_CHECKSUM",
        "62644D69-6D69-5261-7469-6F0000000000" : "MIMI_DSP_RATIO",
        "62644D69-6D69-4473-704F-6E4F66660000" : "MIMI_DSP_ON_OFF",
        "62644D69-6D69-5374-6172-7443616C0000" : "UUID_MIMI_CALIBRATION",
        
        
        "6264546F-7563-6853-6572-766963650000" : "BD_TOUCH_SERVICE",
        "6264546F-7563-6853-656E-736500000000" : "BD_TOUCH_SENSE",
        
        "62644570-5365-7276-6963-650000000000" : "BD_EAR_PATRON_SERVICE",
        "62644570-5265-6164-5065-726300000000" : "BD_EAR_PATRON_READ_PERCENTAGE",
        "62644570-5265-6164-436F-6E7400000000" : "BD_EAR_PATRON_CONT_VALUES",
        "62644570-5274-6300-0000-000000000000" : "BD_EAR_PATRON_RTC" 
    ]
    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
//    var index = 0
//    var isReadingRSSI = false
    var rssiArray: [NSNumber] = []
    var services: [CBService] = []
    var characteristics: [[CBCharacteristic]] = []
    var delegate: BluetoothManagerDelegate?
    
    var currentPeriphiral: CBPeripheral!
    var currentCharacteristic: CBCharacteristic!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn :
            central.scanForPeripherals(withServices: nil, options: nil)
            print("The state is powerdOn")
        case .poweredOff :
            print("The state is powerdOff")
        case .unauthorized :
            print("The state is unauthorized")
        case .unknown :
            print("The state is unknown")
        case .unsupported :
            print("The state is unsupported")
        case .resetting :
            print("The state is resetting")
        }
        print("Scanning: \(central.isScanning)")
        //        statusLabel.text = "Scanning: \(central.isScanning ? "started" : "stopped")"
        
    }
    
    func startScan() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func refreshScan(){
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
//    func startReadRSSI(){
//        while self.isReadingRSSI {
//        for periphiral in self.peripherals {
//            if(isReadingRSSI) {
//                if(self.peripherals.contains(periphiral)) {
//                    self.index = self.peripherals.index(of: periphiral)!
//                    periphiral.delegate = self
//                    periphiral.readRSSI()
//                }
//            }
//            }
//        }
//    }
    
    func discoverForServices(periphiral: CBPeripheral) {
        periphiral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        if(!self.peripherals.contains(peripheral)){
            self.peripherals.append(peripheral)
            self.rssiArray.append(RSSI)
            self.delegate?.discoveredNewPeriphirals!(periphiral: peripheral)
        } else {
            let index = self.peripherals.index(of: peripheral)!
            self.rssiArray.insert(RSSI, at: index)
            NotificationCenter.default.post(name: .newRSSIValue, object: index)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
        }
        switch peripheral.state {
        case .disconnected:
            print("***Disconnected***")
            NotificationCenter.default.post(name: .isConnected, object: false)
            break
        case .disconnecting:
            print("***Disconnecting***")
            break
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("***CONNECTED***")
        NotificationCenter.default.post(name: .isConnected, object: true)
        currentPeriphiral = peripheral
        currentPeriphiral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
        }
        if let services = peripheral.services {
            self.delegate?.discoveredServices!(services: services)
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
        }
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                peripheral.readValue(for: characteristic)
            }
            self.delegate?.discoveredCharacteristics!(characteristics: characteristics)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            print("***DidUpdateValueForCharacteristic***")
            NotificationCenter.default.post(name: .didUpdateValueForCharacteristic, object: value)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if error != nil {
            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
        }
//        self.rssiArray[index] = RSSI
    }

}

extension Notification.Name {
    static let isConnected = Notification.Name("isConnected")
    static let didUpdateValueForCharacteristic = Notification.Name("didUpdateValueForCharacteristic")
    static let newRSSIValue = Notification.Name("newRSSIValue")
}


enum CharacteristicPermissions {
    case read, write, notify
}


extension CBCharacteristic {

    var permissions: Set<CharacteristicPermissions> {
        var permissionsSet = Set<CharacteristicPermissions>()
        
        if self.properties.rawValue & CBCharacteristicProperties.read.rawValue != 0 {
            permissionsSet.insert(CharacteristicPermissions.read)
        }
        
        if self.properties.rawValue & CBCharacteristicProperties.write.rawValue != 0 {
            permissionsSet.insert(CharacteristicPermissions.write)
        }
        
        if self.properties.rawValue & CBCharacteristicProperties.notify.rawValue != 0 {
            permissionsSet.insert(CharacteristicPermissions.notify)
        }
        
        return permissionsSet
    }
    
    func generatePermissionsText() -> String {
        var permissionsText = ""
        if self.permissions.contains(.read) {
            permissionsText += "Read"
        }
        if self.permissions.contains(.write) {
            permissionsText += " / Write"
        }
        if self.permissions.contains(.notify) {
            permissionsText += " / Notify"
        }
        return permissionsText
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
