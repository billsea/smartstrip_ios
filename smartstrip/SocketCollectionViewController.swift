//
//  SocketCollectionViewController.swift
//  smartstrip
//
//  Created by Loud on 7/10/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

struct view_sockets {
	var name : String?
	var image : UIImage?
}

class SocketCollectionViewController: UICollectionViewController {
	
	var cv_items = [view_sockets]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

			self.title = "Socket Status"
			
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

			//data source
			cv_items.append(view_sockets(name: "One", image: nil))
			cv_items.append(view_sockets(name: "Two", image: nil))
			cv_items.append(view_sockets(name: "Three", image: nil))
			cv_items.append(view_sockets(name: "Four", image: nil))
			cv_items.append(view_sockets(name: "Five", image: nil))
			cv_items.append(view_sockets(name: "Six", image: nil))
			
			// Register cell classes
			self.collectionView!.register(UINib(nibName: "SocketCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cv_items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       	let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SocketCollectionViewCell
    
			// Configure the cell
			cell.backgroundColor = UIColor.green;
			cell.cellName.text =  cv_items[indexPath.row].name
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

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

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
