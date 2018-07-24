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

	var selectedPreset : Preset?
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

			self.title = selectedPreset?.name
		
			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
			
			let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
			
			navigationItem.rightBarButtonItems = [editButton]
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
			return (selectedPreset?.sockets?.count)!
		}

		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SocketCollectionViewCell
			
			let socketList = selectedPreset?.sockets?.allObjects as! [Socket]
			
			if((socketList.count) > 0){
				cell.selSocket = socketList[indexPath.row]
				cell.backgroundColor = socketList[indexPath.row].active ? UIColor.green : UIColor.red
				cell.cellName.text =  socketList[indexPath.row].name
			}
			
			return cell
		}
	

		func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			let vc = SocketDetailViewController(nibName: "SocketDetailViewController", bundle: nil)
			vc.cellIndex = indexPath.row
			let cell = self.collectionView.cellForItem(at: indexPath) as! SocketCollectionViewCell
			vc.selSocket = cell.selSocket!
			
			self.navigationController?.pushViewController(vc, animated: false)
			
			return true
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
