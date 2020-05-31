//
//  NowTableViewCell.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 31/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import UIKit

class NowTableViewCell: UITableViewCell {
    var event:EpgEvent?
    
    @IBOutlet weak var hour: UILabel!
    
    @IBOutlet weak var titlelabel: UILabel!
    
    @IBOutlet weak var duration: UILabel!
    
    @IBOutlet weak var progress: UIProgressView!
    
    
    
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
        self.progress.progress = e.getProgress()
    }

}
