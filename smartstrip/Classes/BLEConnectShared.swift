//
//  BLEConnectShared.swift
//  smartstrip
//
//  Created by Loud on 7/25/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

//NOTES:
//<CBPeripheral: 0x105427da0, identifier = 26F927A3-C31C-D452-AEBA-FB2D5FC71825, name = HMSoft, state = disconnected>
//<CBService: 0x105406f10, isPrimary = YES, UUID = FFE0>
//<CBCharacteristic: 0x1014ed3a0, UUID = FFE1, properties = 0x16, value = (null), notifying = NO>


import Foundation
import CoreBluetooth

protocol bleConnectDelegate {
	func connect(connected:Bool)
	func updateCollection(_ socket_index: Int, _ status: Int)
}

enum HW_SOCKET : UInt8 {
	case ONE
	case TWO
	case THREE
	case FOUR
	case ALL
}

private let bleShieldName = "HMSoft"

let bleSharedInstance = BLEConnectShared();

class BLEConnectShared: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
	
	var HmSoftPeripheral: CBPeripheral? //HmSoft BLE Shield
	fileprivate var centralManager: CBCentralManager!
	fileprivate var positionCharacteristic: CBCharacteristic?
	var HmSoftService : CBService?
	
	//TEMP TODO: Un-hardcode these values
	let BLEService = "FFE0"
	let BLECharacteristic = "FFE1"
	
	var bleDelegate: bleConnectDelegate!
	
	override init() {
		super.init()
		
		let centralQueue = DispatchQueue(label: "com.loudsoftware", attributes: [])
		centralManager = CBCentralManager(delegate: self, queue: centralQueue)
	}
	
	//MARK: BLE Calls
	func scanBLEDevices() {
		//if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
		centralManager?.scanForPeripherals(withServices: nil, options: nil)
		
		//stop scanning after 1 seconds
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.stopScanForBLEDevices()
		}
	}
	
	func stopScanForBLEDevices() {
		centralManager?.stopScan()
		if((HmSoftPeripheral) != nil){
			centralManager?.connect(HmSoftPeripheral!, options: nil)
			//notify caller
			bleDelegate.connect(connected: true)
			//alertController.dismiss(animated: true, completion: nil);
		}
	}
	
	//MARK: Write data to ble
	func writeToBLE(value: UInt8){
		var socket_index = Data(count: 1)
		socket_index[0] = value
		
		guard (HmSoftPeripheral?.state)!.rawValue == 2 else {
			//TODO: try to reconnect?
			print("not connected")
			return
		}
		HmSoftPeripheral?.writeValue(socket_index, for: self.positionCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func reset(){
		HmSoftPeripheral = nil
	}
	
	//MARK: Central manager delegates
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		//Start scanning for devices only after central state is powered on
		if(central.state == CBManagerState.poweredOn){
			self.scanBLEDevices()
		}
		print(central.state)
	}
	
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
		//self.collectionView?.isHidden = false //show collection view //TODO
		print("Connected to " +  peripheral.name!)
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		print(error!)
	}
	

	// MARK: BLE Peripheral delegates
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		guard let services = peripheral.services else { return }
		for service in services {
			HmSoftService = service
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
						self.bleDelegate.updateCollection(soc_index - 1,Int(characteristic.value![soc_index]))
						soc_index = soc_index + 1
					}
				} else {
					self.bleDelegate.updateCollection(Int(characteristic.value![0]),Int(characteristic.value![1]))
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

}
