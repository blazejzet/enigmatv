//
//  NowCollectionViewCell.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 27/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import UIKit

class NowCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var channnel: UIImageView!
    var sref:String = ""
    var service:Service?
    var bouquet:Service?
    var event: EpgEvent?
    
    func setup(e:EpgEvent,service:Service,bouquet:Service){
        self.event = e
        var servicename = service.servicename
        self.service = service
        self.bouquet = bouquet
        self.sref = e.sref!
        self.label.text = e.title
        progress.progress = 0;
        poster.image = UIImage(named: "poster_placeholder2")
        let d = Date(timeIntervalSince1970: TimeInterval(integerLiteral: Int64(e.begin_timestamp!) ))
        let d2 = Date(timeIntervalSince1970: TimeInterval(integerLiteral: Int64(e.duration_sec!) ))
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "HH:mm"
        
        let dateString = dayTimePeriodFormatter.string(from: d)
        let durString = "\(Int(e.duration_sec!/60)) min."
        self.time.text = dateString
        self.duration.text = durString
       

        progress.progress = e.getProgress()
        progress.alpha=1.0
        time.alpha = 1.0
        duration.alpha = 1.0
        var name_ = "\(servicename!.lowercased().replacingOccurrences(of: " ", with: ""))"
        self.poster.contentMode = .scaleAspectFill
        self.poster.backgroundColor = .clear
        if (e.title == "N/A"){
            progress.alpha=0.0
            time.alpha = 0.0
            duration.alpha = 0.0
            //self.poster.sd_setImage(with: URL(string: "https://asuri.pl/y/picons/\(name_).png"), completed: nil)
            //self.poster.contentMode = .scaleAspectFit
            self.poster.backgroundColor = .black
            //self.channnel.image = nil
        }
            
            self.channnel.sd_setImage(with: URL(string: "https://asuri.pl/y/picons/\(name_).png"), completed: nil)
            
        
        
        STBAPI.common()?.searchInfoWeb(title: e.title!, duration: Int(e.duration_sec!/60), eid: Int(e.begin_timestamp!) ) {
            image, backdrop, eid, ok in
            if eid != Int(e.begin_timestamp!) {return}
            DispatchQueue.main.sync {
                if (ok ){
                    if (backdrop != nil){
                        self.poster.image = backdrop//image
                        
                    }else{
                        if (image != nil){
                            self.poster.image = image//image
                            
                        }else{
                           
                            self.poster.sd_setImage(with: URL(string: "https://asuri.pl/y/picons/\(name_).png"), completed: nil)
                        }
                    }
                    
                }
                
            }
        }
    }
}
