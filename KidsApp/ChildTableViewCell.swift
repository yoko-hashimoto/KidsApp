//
//  ChildTableViewCell.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/16.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit

class ChildTableViewCell: UITableViewCell {
    
    @IBOutlet weak var childLabel: UILabel!
    @IBOutlet weak var promisePointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
