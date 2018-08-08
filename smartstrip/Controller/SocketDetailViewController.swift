//
//  SocketDetailViewController.swift
//  smartstrip
//
//  Created by Loud on 7/23/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit

class SocketDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	var cellIndex : NSInteger = 0
	var selSocket : Socket!
	var socketList : [Socket] = []
	
	@IBOutlet weak var socketName: UITextField!
	@IBOutlet weak var socketPowerIndex: UISegmentedControl!

	@IBOutlet weak var delayPicker: UIPickerView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.delayPicker.delegate = self
		self.socketName.text = selSocket.name
		self.socketPowerIndex.selectedSegmentIndex = Int(selSocket.power_index)
		
		self.delayPicker.selectRow(Int(selSocket.delay-1), inComponent: 0, animated: true)
		
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		selSocket.name = self.socketName.text
		selSocket.power_index = Int32(self.socketPowerIndex.selectedSegmentIndex)
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 10
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return String(row+1)
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selSocket.delay = Int32(row+1)
	}
	
	
	@IBAction func powerIndexHit(_ sender: Any) {
		
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
