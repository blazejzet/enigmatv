//
//  NextTableViewCell.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 31/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import UIKit

class NextTableViewCell: UITableViewCell {
    
     var event:EpgEvent?
    
    
    @IBOutlet weak var hour: UILabel!
    
    
    @IBOutlet weak var titlelabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
       func setup(e:EpgEvent){
           self.event = e;
           self.titlelabel.text = e.title;
            self.hour.text = e.getBeginTimeString()
       }

}
