//
//  ViewController.swift
//  BLE-Test
//
//  Created by Christian Mansch on 07.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var servicesTextView: UITextView!
    @IBOutlet weak var buttonConnect: UIButton!
    @IBOutlet weak var buttonDisconnect: UIButton!
    @IBOutlet weak var characteristicsTextView: UITextView!
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var headphoneTag: CBPeripheral?
    var services: [CBService]!
    var characteristics: [CBCharacteristic]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.servicesTextView.isEditable = false
        self.characteristicsTextView.isEditable = false
        self.buttonDisconnect.isEnabled = false
    }
    
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
        statusLabel.text = "Scanning: \(central.isScanning ? "started" : "stopped")"
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.identifier.uuidString == "B228A091-8CD7-C338-1FF2-B160D59D2CD8"
        {
            print("The Name is: \(peripheral.name ?? "nil")")
            label1.text = "Connected to: \(peripheral.name!)"
            central.isScanning ? central.stopScan() : print("scanning already stopped")
            headphoneTag = peripheral
            headphoneTag?.delegate = self
            
            if let aventho = headphoneTag {
                central.connect(aventho, options: nil)
            }
        }
        print("Scanning: \(central.isScanning)")
        statusLabel.text? = "Scanning: \(central.isScanning ? "started" : "stopped")"
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("An Error has occoured: \(String(describing: error?.localizedDescription))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            self.services = services
            for service in services {
                servicesTextView.text.append("\n\(service.uuid.uuidString)")
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
                if(characteristic.uuid.uuidString == "62644570-5265-6164-5065-726300000000"){
                    let year = 2017
                    let loByte = year & 0xFF
                    let hiByte = (year >> 8) & 0xFF
                    
                    let day = 18
                    let month = 10
                    let hours = 02
                    let minutes = 59
                    let seconds = 00
                    let mseconds = 00
                    
                    let dateArray:[UInt8] = [0x00, UInt8(loByte), UInt8(hiByte), UInt8(month), UInt8(day), UInt8(hours), UInt8(minutes), UInt8(seconds), UInt8(mseconds)]
                    let data = Data(bytes:dateArray)
                    //peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    characteristicsTextView.text.append("\n" + "bdEpReadPerc found below")
                }
                characteristicsTextView.text.append("\n\(characteristic.uuid)")
                print(characteristic.uuid)
                peripheral.readValue(for: characteristic)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            
            if let data:NSString = NSString(data: value, encoding: 8) {
                print(data)
                characteristicsTextView.text.append("\n\(data)")
            }
        }
    }

    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        switch peripheral.state {
        case .disconnected:
            label1.text = "Disconnected"
        case .disconnecting:
            label1.text = "Disconnecting"
        default:
            break
        }
    }
    
    @IBAction func connect(_ sender: UIButton) {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.buttonConnect.isEnabled = false
        self.buttonDisconnect.isEnabled = true
        self.servicesTextView.text = " Services: "
        self.characteristicsTextView.text = "Characteristics: "
    }
 
    
    
    @IBAction func disconnect(_ sender: UIButton) {
        centralManager.cancelPeripheralConnection(headphoneTag!)
        self.buttonDisconnect.isEnabled = false
        self.buttonConnect.isEnabled = true
    }
 
}
