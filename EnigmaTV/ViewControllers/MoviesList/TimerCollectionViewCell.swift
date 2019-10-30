//
//  TimerCollectionViewCell.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.05.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

class TimerCollectionViewCell: CommonCollectionViewCell {
    var service:RecordingTimer?
    
    override func deleteItem(){
        //STBAPI.common()?.movieDelete(self.service!)
        del?.delete(timer: service!)
    }
    
    func configure(serv:RecordingTimer){
        //self.isUserInteractionEnabled=true
        self.service = serv;
        //self.serviceLabel.text = serv.servicename
        //self.detailsLabel.text = ""
        self.recordingLabel.text = serv.name
        self.dateLabel.text = serv.realbegin
        //self.timeLabel.text = "\(serv.recordingtime!/60) min"
        var tinm = serv.duration! / 60
        
        self.requestImage(name:serv.name!,tinm:Int(tinm),servicename:serv.servicename!)
        
        //self.timeLabel.text = ""
         self.recIcon.text = "🔴"
        self.recordingLabel.text = "\((serv.name)!)"
        //self.delaccv.frame = CGRect(x: self.frame.size.width, y: 0, width: 0, height: self.frame.size.height)
        //self.backgroundColor = UIColor.clear
         super.configure()
        
        
    }
    
    override func getDate()->String?{return self.service?.realbegin};
    override func getTitle()->String?{return self.service?.name};
    override  func getService()->String?{return self.service?.servicename};
    override func getLength()->String?{return "Planned"};
    override func getSize()->String?{return ""};
}
