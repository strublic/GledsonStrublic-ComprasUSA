//
//  ProductTableViewCell.swift
//  GledsonStrublic
//
//  Created by Mobile2you on 18/04/18.
//  Copyright © 2018 Mobile2you. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {

    @IBOutlet weak var lbStateTitle: UILabel!
    @IBOutlet weak var lbStateTax: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
            
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
