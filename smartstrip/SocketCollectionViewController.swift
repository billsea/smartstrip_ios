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

class view_socket {
	var name : String?
	var active : Bool?
	init(name: String?, active : Bool?) {
		self.name = name
		self.active = active
	}
}

class SocketCollectionViewController: UICollectionViewController, UIAlertViewDelegate  {
	var alertController : UIAlertController!
	let bleShared = bleSharedInstance
	
	var cv_items = [view_socket]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

			self.title = "Socket Status"
			
			//hide cv until connection is made
			self.collectionView?.isHidden = true
			
			//set data source
			self.loadManual()

			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
			
			// Discover bluetooth devices
			bleShared.updateCollectionCallback = {(_ socket_index: Int, _ status: Int) -> Void in
				self.updateCollectionData(socket_index: socket_index, status: status)
			}
			
			bleShared.connectCallback = {(_ status: Bool) -> Void in
				//TODO: Add spinner or status update
				self.collectionView?.isHidden = false
				print("connected!")
			}

    }
			
		func loadManual(){
			cv_items.append(view_socket(name: "One", active: true))
			cv_items.append(view_socket(name: "Two",  active: true))
			cv_items.append(view_socket(name: "Three", active: true))
			cv_items.append(view_socket(name: "Four", active: true))
			cv_items.append(view_socket(name: "Five", active: true))
			cv_items.append(view_socket(name: "Six", active: true))
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

		// Uncomment this method to specify if the specified item should be selected
		override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			var sel_index = UInt8(indexPath.row)
			
			if(sel_index < 6){
				if(indexPath.row == 3){
					sel_index = HW_SOCKET.THREE.rawValue
				} else if(indexPath.row >= 4){
					sel_index = HW_SOCKET.FOUR.rawValue
				}
				bleShared.writeToBLE(value: sel_index)
			}
			return true
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
			
			DispatchQueue.main.async() {
				self.collectionView?.reloadData()
			}
			
		}
	
		override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
		}
}

