//
//  DashboardCollectionViewController.swift
//  smartstrip
//
//  Created by Loud on 7/9/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

struct view_data {
	var name : String?
	var image : UIImage?
}

class DashboardCollectionViewController: UICollectionViewController {
	
	var cv_items = [view_data]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

			self.title = "Dashboard";

			//data source
			cv_items.append(view_data(name: "Manual", image: UIImage(named: "help")))
			cv_items.append(view_data(name: "Custom", image: UIImage(named: "help")))
			cv_items.append(view_data(name: "Settings", image: UIImage(named: "help")))

        // Register cell classes
			self.collectionView!.register(UINib(nibName: "DashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
			
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return cv_items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DashboardCollectionViewCell
			
			
        // Configure the cell
			cell.backgroundColor = UIColor.white;
			cell.cellNameLabel.text =  cv_items[indexPath.row].name
			cell.cellImage.image = cv_items[indexPath.row].image
			return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */


    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			
			  let manualViewController = SocketCollectionViewController(nibName: "SocketCollectionViewController", bundle: nil)
			
			  navigationController?.pushViewController(manualViewController, animated: false)
			
        return true
    }


    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
