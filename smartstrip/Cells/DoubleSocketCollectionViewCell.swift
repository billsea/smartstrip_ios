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
	
	var selSocket : Socket?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
