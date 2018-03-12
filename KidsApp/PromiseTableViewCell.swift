//
//  PromiseTableViewCell.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/16.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit

class PromiseTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var promiseLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var promisePointLabel: UILabel!
    @IBOutlet weak var promiseCountLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
