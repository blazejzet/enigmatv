//
//  Event.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import SWXMLHash
import CoreData

class EpgEvent:NSObject ,Translateable{
      var id:Int?
      var begin_timestamp:UInt64?
      var duration_sec:UInt64?
      var now_timestamp:UInt64?
      var remaining:UInt64?
      var title:String?
      var shortdesc:String?
      var longdesc:String?
      var sref:String?       //HAHA!
      var sname:String?
        var end_timestamp:UInt64?{
            (begin_timestamp ?? 0) + (duration_sec ?? 0)
        }
    
    var timer:RecordingTimer? //MOJE
    func getBeginTimeString()->String{
        let ds = Date(timeIntervalSince1970: TimeInterval(self.begin_timestamp!))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        //self.dateLabel.text = dateFormatter.string(from: ds)
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        let dsh =  dateFormatter.string(from: ds)
        return dsh
    }
    
    static var translation: [String : String] = [:]
    
    override init() {
        
    }
    
    init(e:EpgEvent){
        //FROM DM 
    }
    
    
    
    func getProgress()->Float{
        return Float (Double( now_timestamp! - begin_timestamp!) / Double (duration_sec!))
    }
    
    
    required init(xml:XMLIndexer){
        do{
        if let e = xml["e2eventid"].element{
            self.id = Int(e.text)
        }
        }catch{}
        do{
        if let e = xml["e2eventstart"].element{
            self.begin_timestamp = UInt64(e.text)
        }
        }catch{}
        do{
        if let e = xml["e2eventduration"].element{
            self.duration_sec = UInt64(e.text)
        }
        }catch{}
        do{
        if let e = xml["e2eventcurrenttime"].element{
            self.now_timestamp = UInt64(e.text)
        }
        }catch{}
        do{
        if(self.now_timestamp!>self.begin_timestamp!){
            if(now_timestamp!-begin_timestamp! < duration_sec!){
                    self.remaining = duration_sec!-(now_timestamp!-begin_timestamp!)
            }else{
                self.remaining = 0
            }
        }else{
            self.remaining = duration_sec
        }
        }catch{}
        do{
        self.title = xml["e2eventtitle"].element?.text
        }catch{}
        do{
            self.shortdesc = xml["e2eventdescription"].element?.text
        }catch{}
        do{
            self.longdesc = xml["e2eventdescriptionextended"].element?.text
        }catch{}
        do{
            self.sname = xml["e2eventservicename"].element?.text
        }catch{}
        do{
            self.sref = xml["e2eventservicereference"].element?.text
        }catch{}
        
    }
}
