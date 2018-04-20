//
//  ProductTableViewCell.swift
//  GledsonStrublic
//
//  Created by Mobile2you on 18/04/18.
//  Copyright © 2018 Mobile2you. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbState: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbCard: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
