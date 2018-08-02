//
//  DashboardCollectionViewCell.swift
//  smartstrip
//
//  Created by Loud on 7/9/18.
//  Copyright © 2018 Loudsoftware. All rights reserved.
//

import UIKit

class DashboardCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var cellNameLabel: UILabel!
	@IBOutlet weak var cellImage: UIImageView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
			UIView.animate(withDuration: 1.5, animations: {
				self.cellImage.alpha = 1.0
			})
		
    }

}
