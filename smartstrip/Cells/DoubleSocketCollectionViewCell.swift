//
//  DoubleSocketCollectionViewCell.swift
//  smartstrip
//
//  Created by Loud on 7/25/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit

class DoubleSocketCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var cellName: UILabel!
	@IBOutlet weak var cellImage: UIImageView!
	@IBOutlet weak var cellImage2: UIImageView!
	@IBOutlet weak var statusImage: UIImageView!
	
	var selSocket : Socket?
	
    override func awakeFromNib() {
        super.awakeFromNib()
			
			//Style the image view
			self.statusImage.layer.borderWidth = 3
			self.statusImage.layer.borderColor = UIColor.lightGray.cgColor
			self.statusImage.layer.cornerRadius = self.statusImage.frame.size.width/2
    }

}
