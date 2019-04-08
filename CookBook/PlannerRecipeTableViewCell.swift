//
//  PlannerRecipeTableViewCell.swift
//  CookBook
//
//  Created by alejandro Lopez on 1/18/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class PlannerRecipeTableViewCell: UITableViewCell {
   
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var recipePictureimageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
