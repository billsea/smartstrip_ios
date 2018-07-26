//
//  PresetsViewController.swift
//  smartstrip
//
//  Created by Loud on 7/19/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class PresetViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

	let bleShared = bleSharedInstance
	var selectedPreset : Preset?
	var managedContext : NSManagedObjectContext?
	var socketList : [Socket] = []
	var cv_items = [ViewSocket]()
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

			self.title = selectedPreset?.name
		
			guard let appDelegate =
				UIApplication.shared.delegate as? AppDelegate else {
					return
			}
		
			managedContext = appDelegate.persistentContainer.viewContext
		
			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
			
			let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
			
			navigationItem.rightBarButtonItems = [editButton]
		
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.saveContext()
		
		socketList = selectedPreset?.sockets?.allObjects as! [Socket]
		socketList.sort(by: { $0.position < $1.position })
		
		self.collectionView.reloadData()
	}
	
		func save(name: String) {
			
			let entity = NSEntityDescription.entity(forEntityName: "Preset", in: managedContext!)!
			let preset = NSManagedObject(entity: entity,  insertInto: managedContext)
			preset.setValue(name, forKeyPath: "name")
			
			self.saveContext()
		}
	
	
	func saveContext() {
		do {
			try managedContext?.save()
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}
	
	func updateCollectionData(socket_index : Int, status: Int){
		//Update UI - TODO
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

		for socket_item in socketList {
			socket_item.active = status == 0 ? false : true
		}
		
		DispatchQueue.main.async() {
			self.collectionView?.reloadData()
		}
		
	}
	
		// MARK: UICollectionViewDataSource
		func numberOfSections(in collectionView: UICollectionView) -> Int {
			return 1
		}

		func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return (selectedPreset?.sockets?.count)!
		}

		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SocketCollectionViewCell
			
			if((socketList.count) > 0){
				cell.selSocket = socketList[indexPath.row]
				cell.backgroundColor = socketList[indexPath.row].active ? UIColor.green : UIColor.red
				cell.cellName.text =  socketList[indexPath.row].name! + ":" + String(socketList[indexPath.row].power_index + 1)
			}
			
			return cell
		}
	

		func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			let vc = SocketDetailViewController(nibName: "SocketDetailViewController", bundle: nil)
			vc.cellIndex = indexPath.row
			let cell = self.collectionView.cellForItem(at: indexPath) as! SocketCollectionViewCell
			vc.selSocket = cell.selSocket!
			vc.socketList = socketList
			self.navigationController?.pushViewController(vc, animated: false)
			
			return true
		}
	
		@IBAction func powerButtonHit(_ sender: Any) {
			let powerButton = sender as! UISegmentedControl
			self.startPowerSequence(powerUp: (powerButton.selectedSegmentIndex == 0) ? true : false)
		}
	
		func startPowerSequence(powerUp: Bool) {
	
			if(powerUp){
				//power up
				socketList.sort(by: { $0.power_index < $1.power_index })
			} else {
				//power down
				socketList.sort(by: { $0.power_index > $1.power_index })
			}
			
			//Start power up/down sequence
			DispatchQueue.global(qos: .default).async {
				for socketIndex in self.socketList {
					sleep(2)
					DispatchQueue.main.async {
						self.bleShared.writeToBLE(value: UInt8(socketIndex.position))
					}
				}
			}
		}
		
	
		override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

		@objc func editTapped(sender: AnyObject) {
			//let snd = sender as! UIBarButtonItem
			
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
