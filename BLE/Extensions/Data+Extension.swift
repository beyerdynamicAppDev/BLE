//
//  Data+Extension.swift
//  BLE
//
//  Created by Maxim Schleicher on 24.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    func getYearOfLoAndHiByte(loByte:Int, hiByte: Int) -> Int {
        if hiByte == 0 {
            return loByte
        } else {
            return hiByte * 256 + loByte
        }
    }
}
