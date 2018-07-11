//
//  SocketCollectionViewController.swift
//  smartstrip
//
//  Created by Loud on 7/10/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit
import CoreBluetooth

private let reuseIdentifier = "Cell"

struct view_socket {
	var name : String?
	var image : UIImage?
	var selected : Bool?
}

class SocketCollectionViewController: UICollectionViewController, CBCentralManagerDelegate, CBPeripheralDelegate   {
	
	var HmSoftPeripheral: CBPeripheral? //HmSoft BLE Shield
	var centralManager: CBCentralManager!
	var smartStripPeripheral: CBPeripheral!
	
	var cv_items = [view_socket]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

			self.title = "Socket Status"
			
			centralManager = CBCentralManager(delegate: self, queue: nil)
			
			//data source
			cv_items.append(view_socket(name: "One", image: nil, selected: true))
			cv_items.append(view_socket(name: "Two", image: nil, selected: true))
			cv_items.append(view_socket(name: "Three", image: nil, selected: false))
			cv_items.append(view_socket(name: "Four", image: nil, selected: true))
			cv_items.append(view_socket(name: "Five", image: nil, selected: true))
			cv_items.append(view_socket(name: "Six", image: nil, selected: true))
			
			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

    }
	
		override func viewDidAppear(_ animated: Bool) {
			self.scanBLEDevices()
		}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cv_items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       	let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SocketCollectionViewCell
    
			// Configure the cell
			let current_socket = cv_items[indexPath.row] as view_socket
			cell.backgroundColor = current_socket.selected! ? UIColor.green : UIColor.red
			cell.cellName.text =  current_socket.name
			cell.cellImage.image = current_socket.image
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */


    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			
			centralManager?.connect(HmSoftPeripheral!, options: nil)
			
        return true
    }


	
	//MARK: BLE Calls
	
		// MARK: BLE Scanning
		func scanBLEDevices() {
			//manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
			
			//if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
			centralManager?.scanForPeripherals(withServices: nil, options: nil)
			
			//stop scanning after 3 seconds
			DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
				self.stopScanForBLEDevices()
			}
		}
	
		func centralManagerDidUpdateState(_ central: CBCentralManager) {
			print(central.state)
		}
	
		func stopScanForBLEDevices() {
			centralManager?.stopScan()
		}
	
		// MARK: - CBCentralManagerDelegate Methods
		func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
			if(peripheral.name == "HMSoft"){
				peripheral.delegate = self;
				HmSoftPeripheral = peripheral;
			}
			print(peripheral)
		}
	

		// MARK: BLE Connect delegates
		func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
			peripheral.discoverServices(nil)//all services discovered..may be slow
			print("Connected to " +  peripheral.name!)
		}
	
		func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
			print(error!)
		}
	
	
		// MARK: BLE Peripheral delegates
		func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
			guard let services = peripheral.services else { return }
			for service in services {
				print(service)
				peripheral.discoverCharacteristics(nil, for: service)
			}
		}
	
		func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
			 print(service)
		}

    
}

