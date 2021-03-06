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
    var timer = Timer()
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
    
  @objc func readValue() {
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
      let data: Data =  notification.object as! Data
        let date = Date()
        self.timestampLabel.text = self.dateFormatter.string(from: date)
        if data.count == 0 {
            self.stringValueLabel.text = "0"
        } else if data.count == 1 {
            self.stringValueLabel.text = "\([UInt8](data).first!)"
        } else {
          if( "\(self.characteristic.uuid)" == BluetoothManager.sharedInstance.uuidDict.someKeyFor(value: "BD_EAR_PATRON_RTC")) {
            dateLabel.isHidden = false
            // check if data count is greate than 2 for bit data.
            // we can make the parsing better.
            if data.count > 2 {
              // Timer is set for one sec and it can be changed too.
              if presentingViewController is CharacteristicDetailVC {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(CharacteristicDetailVC.readValue)), userInfo: nil, repeats: true)
                let year = data.getYearOfLoAndHiByte(loByte: Int(data[1]), hiByte: Int(data[0]))
                self.dateLabel.text = "\(year)-\(data[2])-\(data[3]) time: \(data[4]):\(data[5]):\(data[6])"
              } else {
                timer.invalidate()
              }
            }
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
