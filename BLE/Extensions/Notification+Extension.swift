//
//  Notification+Extension.swift
//  BLE
//
//  Created by Maxim Schleicher on 24.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let isConnected = Notification.Name("isConnected")
    static let didUpdateValueForCharacteristic = Notification.Name("didUpdateValueForCharacteristic")
    static let newRSSIValue = Notification.Name("newRSSIValue")
}
