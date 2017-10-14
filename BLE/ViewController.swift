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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    characteristicsTextView.text.append("\n" + "bdEpReadPerc found below")
                }
                characteristicsTextView.text.append("\n\(characteristic.uuid)")
                print(characteristic.uuid)
               // peripheral.writeValue(<#T##data: Data##Data#>, for: <#T##CBDescriptor#>)
                peripheral.writeValue(<#T##data: Data##Data#>, for: <#T##CBCharacteristic#>, type: <#T##CBCharacteristicWriteType#>)
                var dateArray = [UInt8]()
//                    = ([
//                        UInt8(00)
//                        , UInt8(2010)    //year
//                        , UInt8(01)     //month
//                        , UInt8(01)     //day
//                        , UInt8(02)     //hour
//                        , UInt8(59)     //minute
//                        , UInt8(00)     //seconds
//                        , UInt8(00)     //mseconds
//                        ])
                let yearLo = UInt8(2017 & 0xFF) // mask to avoid overflow error on conversion to UInt8
                let yearHi = UInt8(2017 >> 8)
                
                dateArray.append(UInt8(00))
                dateArray.append(yearLo)
                dateArray.append(yearHi)
                dateArray.append(UInt8(01))
                dateArray.append(UInt8(01))
                dateArray.append(UInt8(02))
                dateArray.append(UInt8(59))
                dateArray.append(UInt8(00))
                dateArray.append(UInt8(00))
                
                
                let data:Data = Data(dateArray)
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
