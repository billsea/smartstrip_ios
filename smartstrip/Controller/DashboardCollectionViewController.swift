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
			cv_items.append(view_data(name: "Manual", image: UIImage(named: "one_finger-50")))
			cv_items.append(view_data(name: "Presets", image: UIImage(named: "shuffle-50")))
			cv_items.append(view_data(name: "Settings", image: UIImage(named: "settings3-50")))

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
			//cell.backgroundColor = UIColor.white;
			cell.cellNameLabel.text =  cv_items[indexPath.row].name
			cell.cellImage.image = cv_items[indexPath.row].image
			return cell
    }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			
			var vc = UIViewController()
			var animate = false
			
			switch indexPath.row {
			case 0:
				vc = SocketCollectionViewController(nibName: "SocketCollectionViewController", bundle: nil)
				break
			case 1:
				vc = PresetsTableViewController(nibName: "PresetsTableViewController", bundle: nil)
				animate = true
				break
			default:
				break
			}
			
			navigationController?.pushViewController(vc, animated: animate)
			
        return true
    }
    
}
