//
//  BluetoothManager.swift
//  BLE
//
//  Created by Maxim Schleicher on 16.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate {

    class var sharedInstance : BluetoothManager{
        struct Static{
            static let instance = BluetoothManager()
        }
        return Static.instance
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
        //        statusLabel.text = "Scanning: \(central.isScanning ? "started" : "stopped")"
        
    }
    
    

}
