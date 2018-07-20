//
//  PresetsViewController.swift
//  smartstrip
//
//  Created by Loud on 7/19/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit
import CoreData

class PresetsViewController: UIViewController {

	var presets = [NSManagedObject]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

			//set data source
			//self.save(name: "Test")//TEMP
			self.loadPresets()
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
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
