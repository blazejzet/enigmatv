//
//  MovieCollectionViewCell.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.05.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import CloudKit


class MovieCollectionViewCell: CommonCollectionViewCell {
    var service:Movie?
    
    override func deleteItem(){
        //STBAPI.common()?.movieDelete(self.service!)
        del?.delete(movie: service!)
    }
    
    @IBOutlet weak var progress: NSLayoutConstraint!
    override func getTitle()->String?{return self.service?.eventname};
   override  func getService()->String?{return self.service?.servicename};
    override func getLength()->String?{return self.service?.length};
    override func getSize()->String?{return self.service?.filesize_readable};
    override func getDate()->String?{return self.service?.begintime};
    
    func configure(serv:Movie, ck:CKRecord?){
        self.isUserInteractionEnabled=true
        super.configure()
        self.service = serv;
        //self.serviceLabel.text = serv.servicename
        //self.detailsLabel.text = serv.filesize_readable
        self.recordingLabel.text = serv.eventname
        self.dateLabel.text = serv.begintime
        //self.timeLabel.text = "\(serv.recordingtime!/60) min"
        //let tins = UInt64(serv.recordingtime!)
        let tinm = Int(serv.length!) ?? 0
        self.requestImage(name:serv.eventname!,tinm:Int(tinm),servicename:serv.servicename!)
        //self.timeLabel.text = serv.length
        self.recIcon.text = "⚪️"
        self.recordingLabel.text = "\(serv.eventname!)"
        //self.delaccv.frame = CGRect(x: self.frame.size.width, y: 0, width: 0, height: self.frame.size.height)
        //self.backgroundColor = UIColor.clear
        
        if let ck = ck{
            self.recIcon.text = "🔵"
            self.recordingLabel.text = "   \(serv.eventname!)"
            let n = ck["watched"] as? NSNumber
            let s = CGFloat((n?.intValue)!) / 100.0
            //progress.setMultiplier(multiplier: s)
            if let p = progress {
                p.setMultiplier(multiplier: s)
            }
            //let f = self.progress_bar.frame
            //self.progress_bar.frame =
                //CGRect(x: f.origin.x, y: f.origin.y, width: CGFloat(s), height: f.size.height)
            
        }else{
            //let f = self.progress_bar.frame
            //self.progress_bar.frame =
                //CGRect(x: f.origin.x, y: f.origin.y, width: 0.0, height: f.size.height)
            if let p = progress {
                p.setMultiplier(multiplier: 0.0)
            }
            
        }
        
    }
}
