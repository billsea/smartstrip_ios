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

	var selIndexRow : NSInteger = 0
	var selectedPreset : Preset?
	var presets = [NSManagedObject]()
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

			self.title = "Preset"
		
		  self.loadPreset()
		
			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		
		  self.collectionView.delegate = self as? UICollectionViewDelegate
			
			let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
			
			navigationItem.rightBarButtonItems = [editButton]
			
		
    }
	
	func loadPreset() {
		let app = AppDelegate()
		let context = app.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Preset")
		
		do {
			presets = try context.fetch(fetchRequest)
			selectedPreset = presets[selIndexRow] as? Preset
		
			//TODO: Sort preset's socket items by position index
			
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
			} catch let error as NSError {
				print("Could not save. \(error), \(error.userInfo)")
			}
		}
	
	
		// MARK: UICollectionViewDataSource
		func numberOfSections(in collectionView: UICollectionView) -> Int {
			return 1
		}

		func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return (selectedPreset?.socket_item?.count)!
		}

		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SocketCollectionViewCell
			
//			// Configure the cell
			let socketObjects = selectedPreset?.socket_item?.allObjects
			if(socketObjects != nil){
				let current_socket = socketObjects![indexPath.row] as! Socket
				cell.backgroundColor = current_socket.active ? UIColor.green : UIColor.red
				cell.cellName.text =  current_socket.name
			}
			
			return cell
		}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

		@objc func editTapped(sender: AnyObject) {
			let snd = sender as! UIBarButtonItem
			
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
