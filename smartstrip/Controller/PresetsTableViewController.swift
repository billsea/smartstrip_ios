//
//  PresetsTableViewController.swift
//  smartstrip
//
//  Created by Loud on 7/23/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PresetsCell"

class PresetsTableViewController: UITableViewController {

	var presets : [NSManagedObject] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
			
			self.title = NSLocalizedString("Presets", comment:"")
			
			let addButton = UIBarButtonItem(
				title: "Add",
				style: .plain,
				target: self,
				action: #selector(addPreset(sender:))
			)
			
			self.navigationItem.rightBarButtonItem = addButton
			
			self.tableView.register(UINib(nibName: "PresetTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
			
			self.loadPresets()
    }

	
	  @objc func addPreset(sender: UIBarButtonItem) {
			let alert = UIAlertController(title: "Preset Name", message: "Enter a name for preset", preferredStyle: .alert)
			
			alert.addTextField { (textField) in
				textField.placeholder = "Enter preset name"
			}
			
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
				let textField = alert?.textFields![0]
				self.save(name: (textField?.text)!)
			}))
			
			self.present(alert, animated: true, completion: nil)
		}
	
		func loadPresets() {
			//This is the most reliable way I've fount to fetch data with Swift - bill
			guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
				return
			}
			
			let managedContext = appDelegate.persistentContainer.viewContext
			let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Preset")
			
			do {
				presets = try managedContext.fetch(fetchRequest)
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
			
			guard let entity = NSEntityDescription.entity(forEntityName: "Preset", in: managedContext) else {
			   return
			}
			
			let preset = NSManagedObject(entity: entity,  insertInto: managedContext) as! Preset
			preset.setValue(name, forKeyPath: "name")
			preset.setValue(Date(), forKeyPath: "date_created")
			
			var idx = 0
			for number in ["One","Two","Three","Four"] {
				let sockEntity = NSEntityDescription.entity(forEntityName: "Socket", in: managedContext)!
				let tempSock = NSManagedObject(entity: sockEntity,  insertInto: managedContext) as! Socket
				tempSock.setValue(number, forKeyPath: "name")
				tempSock.setValue(true, forKey: "active")
				tempSock.setValue(idx, forKey: "position")
				tempSock.setValue(idx, forKey: "power_index")
				tempSock.setValue(2, forKey: "delay")
				
				preset.addToSockets(tempSock)
				idx = idx + 1
			}

			do {
				try managedContext.save()
				presets.append(preset)
				self.tableView.reloadData()
			} catch let error as NSError {
				print("Could not save. \(error), \(error.userInfo)")
			}
		}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presets.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PresetTableViewCell

			let preset = presets[indexPath.row] as! Preset
			cell.selectedPreset = preset
			
			if let presetName = preset.name {
				cell.cellLabel.text = presetName
			}

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

		override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
			let vc = PresetViewController(nibName: "PresetViewController", bundle: nil)
			let cell = self.tableView.cellForRow(at: indexPath) as! PresetTableViewCell
			vc.selectedPreset = cell.selectedPreset
			self.navigationController?.pushViewController(vc, animated: false)
		}
    
}
