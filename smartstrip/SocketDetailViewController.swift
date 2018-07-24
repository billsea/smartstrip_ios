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
	var selSocket = Socket()
	
	@IBOutlet weak var socketName: UITextField!
	
	@IBOutlet weak var socketPosition: UISegmentedControl!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		self.socketName.text = selSocket.name
        
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
