//
//  SocketCollectionViewController.swift
//  smartstrip
//
//  Created by Loud on 7/10/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"
private let reuseIdentifier2 = "DoubleCell"
private let reuseIdentifier3 = "RightCell"

class SocketCollectionViewController: UICollectionViewController, UIAlertViewDelegate, UICollectionViewDelegateFlowLayout, bleConnectDelegate {
	
	var alertController : UIAlertController!
	let bleShared = bleSharedInstance

	var cv_items = [ViewSocket]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

			self.title = "Socket Status"
			
			//hide cv until connection is made
			self.collectionView?.isHidden = true
			
			self.bleShared.bleDelegate = self
			
			//set data source
			self.loadManual()

			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
			self.collectionView!.register(UINib(nibName: "DoubleSocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier2)
			self.collectionView!.register(UINib(nibName: "RightSocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier3)
			
			//Check if we have a ble peripheral established
			if(self.bleShared.HmSoftPeripheral != nil){
				//peripheral is initialized
				self.connect(connected: true)
				self.bleShared.HmSoftPeripheral?.discoverCharacteristics(nil, for: self.bleShared.HmSoftService!)
			}
    }
			
		func loadManual(){
			cv_items.append(ViewSocket(name: "One", active: true))
			cv_items.append(ViewSocket(name: "Two",  active: true))
			cv_items.append(ViewSocket(name: "Three", active: true))
			cv_items.append(ViewSocket(name: "Four", active: true))
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
	
	//MARK: Ble Connect Delegate
	func connect(connected: Bool) {
			self.collectionView?.isHidden = false
			print("connected!")
	}
	
	func updateCollection(_ socket_index: Int, _ status: Int) {
		self.updateCollectionData(socket_index: socket_index, status: status)
	}
	

		// MARK: UICollectionViewDataSource
		override func numberOfSections(in collectionView: UICollectionView) -> Int {
				return 1
		}

		override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
				return cv_items.count
		}
	
	
		func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
			if(indexPath.row < 2){
				return CGSize(width: 180, height: 160)
			} else {
				return CGSize(width: collectionView.frame.width - 20, height: 160)
			}
		}

		override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			
			if(indexPath.row == 0){
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SocketCollectionViewCell
				let current_socket = cv_items[indexPath.row] as ViewSocket
				cell.statusImage.backgroundColor = current_socket.active! ? UIColor.green : UIColor.darkGray
				cell.cellName.text =  current_socket.name
				return cell
			} else if(indexPath.row == 1){
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier3, for: indexPath) as! RightSocketCollectionViewCell
				let current_socket = cv_items[indexPath.row] as ViewSocket
				cell.statusImage.backgroundColor = current_socket.active! ? UIColor.green : UIColor.darkGray
				cell.cellName.text =  current_socket.name
				return cell
			} else {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! DoubleSocketCollectionViewCell
				let current_socket = cv_items[indexPath.row] as ViewSocket
				cell.statusImage.backgroundColor = current_socket.active! ? UIColor.green : UIColor.darkGray
				cell.cellName.text =  current_socket.name
				return cell
			}
			
		}

		// MARK: UICollectionViewDelegate

		// Uncomment this method to specify if the specified item should be selected
		override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			
			let sel_index = UInt8(indexPath.row)
			bleShared.writeToBLE(value: sel_index)
			return true
		}

		func updateCollectionData(socket_index : Int, status: Int){
			//Update UI
			let sel_socket = cv_items[socket_index] as ViewSocket
			sel_socket.active = status == 0 ? false : true

			DispatchQueue.main.async() {
				self.collectionView?.reloadData()
			}
			
		}
	
		override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
		}
}

