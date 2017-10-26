//
//  CBCharacteristic+Extension.swift
//  BLE
//
//  Created by Maxim Schleicher on 24.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

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
