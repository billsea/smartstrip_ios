//
//  RightSocketCollectionViewCell.swift
//  smartstrip
//
//  Created by Loud on 7/31/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit

class RightSocketCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var cellName: UILabel!
	@IBOutlet weak var cellImage: UIImageView!
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
