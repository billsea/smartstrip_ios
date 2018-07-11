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
private let bleShieldName = "HMSoft"

struct view_socket {
	var name : String?
	var image : UIImage?
	var selected : Bool?
}

//<CBPeripheral: 0x105427da0, identifier = 26F927A3-C31C-D452-AEBA-FB2D5FC71825, name = HMSoft, state = disconnected>
//<CBService: 0x105406f10, isPrimary = YES, UUID = FFE0>
//<CBCharacteristic: 0x1014ed3a0, UUID = FFE1, properties = 0x16, value = (null), notifying = NO>

class SocketCollectionViewController: UICollectionViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UIAlertViewDelegate  {
	
	var HmSoftPeripheral: CBPeripheral? //HmSoft BLE Shield
	var centralManager: CBCentralManager!
	var positionCharacteristic: CBCharacteristic?
	
	var alertController : UIAlertController!
	
	//TEMP
	let BLEService = "FFE0"
	let BLECharacteristic = "FFE1"
	
	var cv_items = [view_socket]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

			self.title = "Socket Status"
			
			//hide cv until connection is made
			self.collectionView?.isHidden = true
			
			centralManager = CBCentralManager(delegate: self, queue: nil)
			
			//data source
			cv_items.append(view_socket(name: "One", image: UIImage(named: "help"), selected: true))
			cv_items.append(view_socket(name: "Two", image: UIImage(named: "help"), selected: true))
			cv_items.append(view_socket(name: "Three", image: UIImage(named: "help"), selected: false))
			cv_items.append(view_socket(name: "Four", image: UIImage(named: "help"), selected: true))
			cv_items.append(view_socket(name: "Five", image: UIImage(named: "help"), selected: true))
			cv_items.append(view_socket(name: "Six", image: UIImage(named: "help"), selected: true))
			
			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

    }
	
		override func viewDidAppear(_ animated: Bool) {
			if((HmSoftPeripheral == nil) || HmSoftPeripheral?.state == CBPeripheralState.disconnected){
				self.scanBLEDevices()
				self.showProgressAlert()
			}
		}
	
	func showProgressAlert() {
		alertController = UIAlertController(title: nil, message: "Connecting...\n\n", preferredStyle: .alert)
		
		let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		
	  let spinX = (alertController.view.frame.size.width/2) - (spinnerIndicator.frame.size.width/2)
		spinnerIndicator.center = CGPoint(x: spinX, y: 105.5)
		spinnerIndicator.color = UIColor.black
		spinnerIndicator.startAnimating()
		
		alertController.view.addSubview(spinnerIndicator)
		self.present(alertController, animated: false, completion: nil)
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
			var sel_index = indexPath.row
			if(sel_index < 6){
				if(indexPath.row == 3){
					sel_index = 2
				} else if(indexPath.row >= 4){
					sel_index = 3
				}
				let position_string = String(sel_index)
				let position_string_data = position_string.data(using: String.Encoding.utf8)
				
				//TODO: CBCharacteristicWriteType.withResponse doesn't write data....need a way to get the
				// on-off status from the bluetooth shield somehow
				HmSoftPeripheral?.writeValue(position_string_data!, for: self.positionCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
			}
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
			if((HmSoftPeripheral) != nil){
				centralManager?.connect(HmSoftPeripheral!, options: nil)
				//dismiss the progress dialog:
				alertController.dismiss(animated: true, completion: nil);
			}
		}
	
		// MARK: - CBCentralManagerDelegate Methods
		func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
			if(peripheral.name == bleShieldName){
				peripheral.delegate = self;
				HmSoftPeripheral = peripheral;
			}
			print(peripheral)
		}
	

		// MARK: BLE Connect delegates
		func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
			peripheral.discoverServices(nil)//all services discovered..may be slow
			self.collectionView?.isHidden = false //show collection view
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
		if (peripheral != self.HmSoftPeripheral) {
			// Wrong Peripheral
			return
		}
		
		if (error != nil) {
			return
		}
		
		if (service.uuid.uuidString == BLEService) {
			
			for characteristic in service.characteristics! {
				
				if (characteristic.uuid.uuidString == BLECharacteristic) {
					//we'll save the reference, we need it to write data
					positionCharacteristic = characteristic
					
					peripheral.discoverDescriptors(for: characteristic)
					
					//Set Notify is useful to read incoming data async
					peripheral.setNotifyValue(true, for: characteristic)
					print("Found HMSoft Data Characteristic")
				}
				
			}
		}
	}

	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		if (characteristic.uuid.uuidString == BLECharacteristic) {
			//data recieved
			if(characteristic.value != nil) {
				let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
				print(stringValue)
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		print(characteristic)
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
		print(characteristic.descriptors!)
	} 
}

