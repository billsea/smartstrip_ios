//
//  SocketDetailViewController.swift
//  smartstrip
//
//  Created by Loud on 7/23/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit

class SocketDetailViewController: UIViewController {

	var cellIndex : NSInteger = 0
	var selSocket : Socket!
	var socketList : [Socket] = []
	
	@IBOutlet weak var socketName: UITextField!
	@IBOutlet weak var socketPowerIndex: UISegmentedControl!

	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.socketName.text = selSocket.name
		self.socketPowerIndex.selectedSegmentIndex = Int(selSocket.power_index)
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		selSocket.name = self.socketName.text
		
		let selIdx = Int32(self.socketPowerIndex.selectedSegmentIndex)
		
		switch self.selSocket.position {
		case 2:
			socketList[3].power_index = selIdx
			break
		case 3:
			socketList[2].power_index = selIdx
			break
		case 4:
			socketList[5].power_index = selIdx
		case 5:
			socketList[4].power_index = selIdx
		default:
			break
		}
		
		selSocket.power_index = selIdx
		
		self.showPairAlert()
		
	}
	
	@IBAction func powerIndexHit(_ sender: Any) {
		if(self.selSocket.position >= 2) {
			self.showPairAlert()
		}
	}
	
	func showPairAlert(){
		let alert = UIAlertController(title: "Socket Pair", message: "Socket pairs will be kept in sync", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
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
