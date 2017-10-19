//
//  ScanningForDevicesTableVC.swift
//  BLE
//
//  Created by Maxim Schleicher on 16.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanningForDevicesTableVC: UITableViewController, BluetoothManagerDelegate {
    
    func discoveredNewPeriphirals(periphiral: CBPeripheral) {
        self.peripherals.append(periphiral)
        self.tableView.reloadData()
    }

    var peripherals: [CBPeripheral] = []
    var delegate: BluetoothManagerDelegate!
    var btManager = BluetoothManager.sharedInstance
    var centralManager: CBCentralManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshBarButtonTapped))
        self.navigationItem.rightBarButtonItems = [refreshBarButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(BluetoothManager.sharedInstance.currentPeriphiral != nil) {
            centralManager.cancelPeripheralConnection(BluetoothManager.sharedInstance.currentPeriphiral)
        }
        self.peripherals = []
        BluetoothManager.sharedInstance.delegate = self
        BluetoothManager.sharedInstance.startScan()
        self.centralManager = BluetoothManager.sharedInstance.centralManager
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
        if(currentPeriphiral.name != nil) {
            cell.textLabel?.text = currentPeriphiral.name! + " RSSI:\(btManager.rssiArray[indexPath.row])"
        } else {
            cell.textLabel?.text = "RSSI:\(btManager.rssiArray[indexPath.row])"
        }
        cell.detailTextLabel?.text = currentPeriphiral.identifier.uuidString
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.centralManager.stopScan()
        self.centralManager.connect(self.peripherals[indexPath.row], options: nil)
        self.performSegue(withIdentifier: "PeriphiralDetailSegue", sender: self.peripherals[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PeriphiralDetailSegue") {
            if let vc = segue.destination as? PeriphiralDetailTableVC {
                vc.periphiral = sender as! CBPeripheral
                
            }
        } 
    }
    
    @objc func refreshBarButtonTapped(){
        BluetoothManager.sharedInstance.refreshScan()
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

    
    


}
