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
    
    @IBOutlet var actionButton: UIBarButtonItem!
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
        self.actionButton.isEnabled = false
        if self.characteristic.permissions.contains(.write) {
            self.actionButton.isEnabled = true
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

//    @objc func insertBarButtonTapped(_ sender: UIButton) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
//        self.datePicker = vc.datePicker
//        vc.modalPresentationStyle = .popover
//        self.present(vc, animated: true, completion: nil)
//        
//        //self.navigationController?.presentedViewController?.present(vc, animated: true, completion: nil)
//        //self.navigationController?.pushViewController(vc, animated: true)
//        //self.present(vc, animated: true, completion: nil)
//    }
    
    @objc func updateValue(notification:Notification){
        let data:Data = notification.object as! Data
        let date = Date()
        self.timestampLabel.text = self.dateFormatter.string(from: date)
        if data.count == 0 {
            self.stringValueLabel.text = "0"
        } else if data.count == 1 {
            self.stringValueLabel.text = "\([UInt8](data).first!)"
        } else {
            if( "\(self.characteristic.uuid)" == BluetoothManager.sharedInstance.uuidDict.someKeyFor(value: "BD_EAR_PATRON_RTC")) {
                dateLabel.isHidden = false
                let yearData = data.subdata(in: 0..<2)
                let year = Data().getYearOfLoAndHiByte(loByte: Int(yearData[1]), hiByte: Int(yearData[0]))
                let month = Int(data[2])
                let day = Int(data[3])
                let hour = Int(data[4])
                let minutes = Int(data[5])
                let seconds = Int(data[6])
                //let year = UInt16(yearData.hexEncodedString(), radix: 16)
                
                
                dateLabel.text = "\(year)-\(month)-\(day)-\(hour)-\(minutes)-\(seconds)"
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
