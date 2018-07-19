//
//  SocketCollectionViewController.swift
//  smartstrip
//
//  Created by Loud on 7/10/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

private let reuseIdentifier = "Cell"
private let bleShieldName = "HMSoft"

enum HW_SOCKET : UInt8 {
	case ONE
	case TWO
	case THREE
	case FOUR
	case ALL
}

class view_socket {
	var name : String?
	var active : Bool?
	init(name: String?, active : Bool?) {
		self.name = name
		self.active = active
	}
}

//<CBPeripheral: 0x105427da0, identifier = 26F927A3-C31C-D452-AEBA-FB2D5FC71825, name = HMSoft, state = disconnected>
//<CBService: 0x105406f10, isPrimary = YES, UUID = FFE0>
//<CBCharacteristic: 0x1014ed3a0, UUID = FFE1, properties = 0x16, value = (null), notifying = NO>

class SocketCollectionViewController: UICollectionViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UIAlertViewDelegate  {
	
	var HmSoftPeripheral: CBPeripheral? //HmSoft BLE Shield
	var centralManager: CBCentralManager!
	var positionCharacteristic: CBCharacteristic?
	var alertController : UIAlertController!
	
	var isManual : Bool?
	
	var presets = [NSManagedObject]()
	
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
			
			//set data source
			//self.save(name: "Test")//TEMP
			isManual! ? self.loadManual() : self.loadPresets()

			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

    }
	
		override func viewWillAppear(_ animated: Bool) {
			self.showProgressAlert()
		}
			
		func loadManual(){
			cv_items.append(view_socket(name: "One", active: true))
			cv_items.append(view_socket(name: "Two",  active: true))
			cv_items.append(view_socket(name: "Three", active: true))
			cv_items.append(view_socket(name: "Four", active: true))
			cv_items.append(view_socket(name: "Five", active: true))
			cv_items.append(view_socket(name: "Six", active: true))
		}
	
		func loadPresets() {
			let app = AppDelegate()
			let context = app.persistentContainer.viewContext
			let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Preset")
			
			do {
				presets = try context.fetch(fetchRequest)
				//Example .... temp
				let presetOne = presets[0] as! Preset
				let pname = presetOne.name
				let pnameAlt = presetOne.value(forKeyPath: "name") as? String
				
			} catch let error as NSError {
				print("Could not fetch. \(error), \(error.userInfo)")
			}
		}
	
		func save(name: String) {
			guard let appDelegate =
				UIApplication.shared.delegate as? AppDelegate else {
					return
			}
			
			let managedContext = appDelegate.persistentContainer.viewContext
			let entity = NSEntityDescription.entity(forEntityName: "Preset", in: managedContext)!
			let preset = NSManagedObject(entity: entity,  insertInto: managedContext)
			preset.setValue(name, forKeyPath: "name")
			
			do {
				try managedContext.save()
				presets.append(preset)
			} catch let error as NSError {
				print("Could not save. \(error), \(error.userInfo)")
			}
		}
	
		func showProgressAlert() {
			alertController = UIAlertController(title: nil, message: "Connecting...\n\n", preferredStyle: .alert)
			
			let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
			
			let spinX = (alertController.view.frame.size.width/2) - (spinnerIndicator.frame.size.width/2)
			spinnerIndicator.center = CGPoint(x: spinX-10, y: 105.5)
			spinnerIndicator.color = UIColor.black
			spinnerIndicator.startAnimating()
			
			alertController.view.addSubview(spinnerIndicator)
			self.present(alertController, animated: false, completion: nil)
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
				cell.backgroundColor = current_socket.active! ? UIColor.green : UIColor.red
				cell.cellName.text =  current_socket.name
		
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
			var sel_index = UInt8(indexPath.row)
			
			if(sel_index < 6){
				if(indexPath.row == 3){
					sel_index = HW_SOCKET.THREE.rawValue
				} else if(indexPath.row >= 4){
					sel_index = HW_SOCKET.FOUR.rawValue
				}
				self.writeToBLE(value: sel_index)
			}
			return true
		}
	
		//MARK: Write to ble
		func writeToBLE(value: UInt8){
			var socket_index = Data(count: 1)
			socket_index[0] = value

			HmSoftPeripheral?.writeValue(socket_index, for: self.positionCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
		}

		func updateCollectionData(socket_index : Int, status: Int){
			//Update UI
			var socket_change = [NSInteger]()
			
			if(socket_index == 2){
				socket_change.append(2)
				socket_change.append(3)
			} else if (socket_index == 3){
				socket_change.append(4)
				socket_change.append(5)
			} else {
				socket_change.append(socket_index)
			}

			for item in socket_change {
				let sel_socket = cv_items[item] as view_socket
				sel_socket.active = status == 0 ? false : true
			}
			
			self.collectionView?.reloadData()
		}
	//MARK: BLE Calls

		// MARK: BLE Scanning
		func scanBLEDevices() {
			//if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
			centralManager?.scanForPeripherals(withServices: nil, options: nil)
			
			//stop scanning after 1 seconds
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
				self.stopScanForBLEDevices()
			}
		}

		func centralManagerDidUpdateState(_ central: CBCentralManager) {
			//Start scanning for devices only after central state is powered on
			if(central.state == CBManagerState.poweredOn){
				self.scanBLEDevices()
			}
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
						self.writeToBLE(value: HW_SOCKET.ALL.rawValue)//get socket status
						
						//Set Notify is useful to read incoming data async
						peripheral.setNotifyValue(true, for: characteristic)
						print("Found HMSoft Data Characteristic")
					}
					
				}
			}
		}

		//Reads from Arduino serial monitor
		func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
			if (characteristic.uuid.uuidString == BLECharacteristic) {
				//data recieved
				if(characteristic.value != nil) {
					//check for status indicator
					if(Int(characteristic.value![0]) == HW_SOCKET.ALL.rawValue){
						//arduino pin status
						var soc_index = 1 //pin status starts at index one
						while soc_index < (characteristic.value?.count)! {
							self.updateCollectionData(socket_index: soc_index - 1, status: Int(characteristic.value![soc_index]))
							soc_index = soc_index + 1
						}
					} else {
					self.updateCollectionData(socket_index: Int(characteristic.value![0]), status: Int(characteristic.value![1]))
					}
				}
			}
		}
	
		func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
			print(characteristic)
		}
	
		func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
			print(characteristic.descriptors!)
		}
	
		override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
		}
}

