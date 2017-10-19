//
//  PeriphiralDetailTableVCTableViewController.swift
//  BLE
//
//  Created by Maxim Schleicher on 16.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeriphiralDetailTableVC: UITableViewController, BluetoothManagerDelegate{
    
    func discoveredServices(services: [CBService]) {
        self.services = services
//        self.removeLoadingScreen()
//        self.tableView.reloadData()
    }
    
    func discoveredCharacteristics(characteristics: [CBCharacteristic]) {
        self.characteristics.append(characteristics)
        if(self.services.count == self.characteristics.count) {
            self.removeLoadingScreen()
            self.tableView.reloadData()
        }
    }

    let loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    var periphiral: CBPeripheral!
    var services: [CBService] = []
    var characteristics: [[CBCharacteristic]] = []
    var centralManager: CBCentralManager!
    var btManager: BluetoothManager!
    var delegate: BluetoothManagerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLoadingScreen()
        self.services = []
        self.characteristics = []
        self.btManager = BluetoothManager.sharedInstance
        self.centralManager = btManager.centralManager
        BluetoothManager.sharedInstance.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(isConnected), name: .isConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCell), name: .newRSSIValue, object: nil)
//        if let services = periphiral.services {
//            self.services = services
//        }
//        for service in self.services {
//            if let tempArray = service.characteristics {
//                characteristics.append(tempArray)
//            } else {
//                characteristics.append([])
//            }
//        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.btManager.discoverForServices(periphiral: self.periphiral)
    }
    
    @objc func isConnected(notification:Notification){
        self.title = "\((notification.object != nil) ? "Connected" : "Disconnected" ) "
    }
    
    @objc func reloadCell(notification: Notification) {
        self.tableView.reloadData()
//        let indexPath = IndexPath(row: notification.object as! Int, section: 0)
//        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if error != nil {
//            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
//        }
//
//        if let services = peripheral.services {
//            self.services = services
//            for service in self.services {
//                peripheral.discoverCharacteristics(nil, for: service)
//            }
//        }
//    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if error != nil {
//            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
//        }
//        if let characteristics:[CBCharacteristic] = service.characteristics {
//            self.characteristics.append(characteristics)
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(self.services[section].uuid)"
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width - 2, height: 40))
        let headerLabel = UILabel(frame: CGRect(x: 5, y: 2, width: tableView.bounds.size.width - 2, height: 40))
        let uuid = String(describing: self.services[section].uuid)
        if let valueOfDict = btManager.uuidDict[uuid] {
            headerLabel.text = valueOfDict
        } else {
            headerLabel.text = uuid
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = UIColor.red
        return headerView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.services.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.characteristics[section].count
    }
        

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "charecteristicCell", for: indexPath)

        let characteristic = self.characteristics[indexPath.section][indexPath.row]
        let uuid = "\(characteristic.uuid)"
        if let valueOfDict = btManager.uuidDict[uuid] {
            cell.textLabel?.text = valueOfDict
        } else {
            cell.textLabel?.text = uuid
        }
        
        //cell.detailTextLabel?.text = "\(characteristic.value)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "CharacteristicDetailSegue", sender: self.characteristics[indexPath.section][indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CharacteristicDetailSegue") {
            if let vc = segue.destination as? CharacteristicDetailVC {
                vc.characteristic = sender as! CBCharacteristic
                
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
    
    private func setLoadingScreen() {
        self.tableView.separatorStyle = .none
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        activityIndicator.startAnimating()
        
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        
        self.tableView.addSubview(loadingView)
        
    }
    
    private func removeLoadingScreen() {
        self.tableView.separatorStyle = .singleLine
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        loadingLabel.isHidden = true
        
    }

}
