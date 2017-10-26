//
//  Dictonary+Extension.swift
//  BLE
//
//  Created by Maxim Schleicher on 24.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit

extension Dictionary where Value: Equatable {
    func someKeyFor(value: Value) -> Key? {
        guard let index = index(where: { $0.1 == value }) else {
            return nil
        }
        return self[index].0
    }
}
