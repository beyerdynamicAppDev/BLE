//
//  DatePickerVC.swift
//  BLE
//
//  Created by Maxim Schleicher on 18.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

class DatePickerVC: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet var datePicker: UIDatePicker!
    var delegate:UIAlertViewDelegate!
    var sendingData: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor.clear
        //view.isOpaque = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        var alertMessage = ""
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day,.month,.year,.hour,.minute], from: self.datePicker.date)
        if let day = components.day, let month = components.month, let year = components.year, let hour = components.hour, let minute = components.minute {
            let firstComponent = 00
            let loByte = year & 0xFF
            let hiByte = (year >> 8) & 0xFF
            let seconds = 00
            let mseconds = 00
            
            alertMessage += "\(firstComponent < 10 ? "0\(firstComponent)" : "\(firstComponent)")-"
            alertMessage += "\(year)-"
            alertMessage += "\(month < 10 ? "0\(month)" : "\(month)")-"
            alertMessage += "\(day < 10 ? "0\(day)" : "\(day)")-"
            alertMessage += "\(hour < 10 ? "0\(hour)" : "\(hour)")-"
            alertMessage += "\(minute < 10 ? "0\(minute)" : "\(minute)")-"
            alertMessage += "\(seconds < 10 ? "0\(seconds)" : "\(seconds)")-"
            alertMessage += "\(mseconds < 10 ? "0\(mseconds)" : "\(mseconds)")"
            
            
            let dateArray:[UInt8] = [UInt8(firstComponent), UInt8(loByte), UInt8(hiByte), UInt8(month), UInt8(day), UInt8(hour), UInt8(minute), UInt8(seconds), UInt8(mseconds)]
            self.sendingData = Data(bytes:dateArray)
        }
        let alertController = UIAlertController(title: "Sending", message: alertMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Send", style: .default) { (action:UIAlertAction!) in
            
            BluetoothManager.sharedInstance.currentPeriphiral.writeValue(self.sendingData!, for: BluetoothManager.sharedInstance.currentCharacteristic, type: CBCharacteristicWriteType.withResponse)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            print("Cancel")
        })
        self.present(alertController, animated: true)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
