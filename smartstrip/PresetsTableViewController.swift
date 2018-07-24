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
         self.navigationItem.rightBarButtonItem = self.editButtonItem
			
			self.tableView.register(UINib(nibName: "PresetTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
			
			//set data source
			//self.save(name: "TestWithSocket")//TEMP
			self.loadPresets()
    }

	
		func loadPresets() {
			
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
			let entity = NSEntityDescription.entity(forEntityName: "Preset", in: managedContext)!
			let preset = NSManagedObject(entity: entity,  insertInto: managedContext) as! Preset
			preset.setValue(name, forKeyPath: "name")
			
			
			//TEMP: TODO REMOVE
			for number in [0,1,2,3,4,5] {
				let sockEntity = NSEntityDescription.entity(forEntityName: "Socket", in: managedContext)!
				let tempSock = NSManagedObject(entity: sockEntity,  insertInto: managedContext) as! Socket
				tempSock.setValue(String(number), forKeyPath: "name")
				preset.addToSockets(tempSock)
			}

			
			do {
				try managedContext.save()
				presets.append(preset)
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
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
