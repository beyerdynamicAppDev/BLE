//
//  CharacteristicDetailVC.swift
//  BLE
//
//  Created by Maxim Schleicher on 18.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth
class CharacteristicDetailVC: UIViewController {

    var characteristic: CBCharacteristic!
    let dateFormatter = DateFormatter()
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        readValue()
    }
    
    @IBOutlet var permissionsTextLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var stringValueLabel: UILabel!
    @IBOutlet var hexValueLabel: UILabel!
    @IBOutlet var dateLabel:UILabel!
    var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.isHidden = true
        self.dateFormatter.dateFormat = "HH:mm:ss"
        NotificationCenter.default.addObserver(self, selector: #selector(updateValue), name: .didUpdateValueForCharacteristic, object: nil)
        
        if self.characteristic.permissions.contains(.write) {
            let insertBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(insertBarButtonTapped))
            self.navigationItem.rightBarButtonItems = [insertBarButton]
        }
        
        if let valueOfDict = BluetoothManager.sharedInstance.uuidDict[self.characteristic.uuid.uuidString] {
            self.title = valueOfDict
        } else {
            self.title = "\(self.characteristic.uuid)"
        }
        
        self.permissionsTextLabel.text = self.characteristic.generatePermissionsText()
        self.readValue()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BluetoothManager.sharedInstance.currentCharacteristic = self.characteristic
        
    }
    
    func readValue() {
        BluetoothManager.sharedInstance.currentPeriphiral.readValue(for: self.characteristic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func insertBarButtonTapped() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        self.datePicker = vc.datePicker
        self.navigationController?.pushViewController(vc, animated: true)
        //self.present(vc, animated: true, completion: nil)
    }
    
    @objc func updateValue(notification:Notification){
        let data:Data = notification.object as! Data
        let date = Date()
        self.timestampLabel.text = self.dateFormatter.string(from: date)
        if data.count == 0 {
            self.stringValueLabel.text = "0"
        } else if data.count == 1 {
            self.stringValueLabel.text = "\([UInt8](data).first!)"
        } else {
            if( "\(self.characteristic.uuid)" == "62644570-5274-6300-0000-000000000000") {
                dateLabel.isHidden = false
                let year = data.subdata(in: 0..<2)
                var month = Int(data[2])
                var day = Int(data[3])
                var hour = Int(data[4])
                var minutes = Int(data[5])
                var seconds = Int(data[6])
                let x = UInt16(year.hexEncodedString(), radix: 16)
                dateLabel.text = "\(x!)-\(month)-\(day)-\(hour)-\(minutes)-\(seconds)"
            }
            
            self.stringValueLabel.text =  String(data: data, encoding: String.Encoding.utf8)
        }
        self.hexValueLabel.text = data.hexEncodedString()
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
