//
//  ScanningForDevicesTableVC.swift
//  BLE
//
//  Created by Maxim Schleicher on 16.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanningForDevicesTableVC: UITableViewController, CBCentralManagerDelegate ,CBPeripheralDelegate {

    var peripherals: [CBPeripheral] = []
    var delegate: CBCentralManagerDelegate!
    var centralManager: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.peripherals = []
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.peripherals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "periphiralCell", for: indexPath)

        let currentPeriphiral = self.peripherals[indexPath.row]

        //currentPeriphiral.readRSSI()
        cell.textLabel?.text = currentPeriphiral.name
        cell.detailTextLabel?.text = currentPeriphiral.identifier.uuidString
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.centralManager.stopScan()
        self.performSegue(withIdentifier: "PeriphiralDetailSegue", sender: self.peripherals[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PeriphiralDetailSegue") {
            if let vc = segue.destination as? PeriphiralDetailTableVC {
                self.centralManager.connect(sender as! CBPeripheral, options: nil)
                vc.periphiral = sender as! CBPeripheral
                
            }
        }
        
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print(RSSI)
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if(!self.peripherals.contains(peripheral)){
            self.peripherals.append(peripheral)
        }
        self.tableView.reloadData()
//        if peripheral.identifier.uuidString == "B228A091-8CD7-C338-1FF2-B160D59D2CD8"
//        {
//            print("The Name is: \(peripheral.name ?? "nil")")
//            label1.text = "Connected to: \(peripheral.name!)"
//            central.isScanning ? central.stopScan() : print("scanning already stopped")
//            headphoneTag = peripheral
//            headphoneTag?.delegate = self
//
//            if let aventho = headphoneTag {
//                central.connect(aventho, options: nil)
//            }
//        }
        print("Scanning: \(central.isScanning)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("An Error has occoured: \(String(describing: error?.localizedDescription))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let services = peripheral.services {
//            self.services = services
//            for service in services {
//                servicesTextView.text.append("\n\(service.uuid.uuidString)")
//                peripheral.discoverCharacteristics(nil, for: service)
//            }
//        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
        }
        
//        if let characteristics = service.characteristics {
//            for characteristic in characteristics {
//                if(characteristic.uuid.uuidString == "62644570-5265-6164-5065-726300000000"){
//                    let year = 2017
//                    let loByte = year & 0xFF
//                    let hiByte = (year >> 8) & 0xFF
//
//                    let day = 18
//                    let month = 10
//                    let hours = 02
//                    let minutes = 59
//                    let seconds = 00
//                    let mseconds = 00
//
//                    let dateArray:[UInt8] = [0x00, UInt8(loByte), UInt8(hiByte), UInt8(month), UInt8(day), UInt8(hours), UInt8(minutes), UInt8(seconds), UInt8(mseconds)]
//                    let data = Data(bytes:dateArray)
//                    //peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
//                    characteristicsTextView.text.append("\n" + "bdEpReadPerc found below")
//                }
//                characteristicsTextView.text.append("\n\(characteristic.uuid)")
//                print(characteristic.uuid)
//                peripheral.readValue(for: characteristic)
//            }
//        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let value = characteristic.value {
//
//            if let data:NSString = NSString(data: value, encoding: 8) {
//                print(data)
//                characteristicsTextView.text.append("\n\(data)")
//            }
//        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        switch peripheral.state {
        case .disconnected:
            break
        case .disconnecting:
            break
        default:
            break
        }
    }

}
