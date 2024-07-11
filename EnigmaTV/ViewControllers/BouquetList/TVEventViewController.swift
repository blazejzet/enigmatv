//
//  TVEventViewController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 30/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import UIKit

class TVEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let events = events{
            return 2 + events.count
        }
        return 1
    }
    
    
    var bouquet:Service?
    var service:Service?
    var event:EpgEvent?
    var now:EpgEvent?
    
    @IBOutlet weak var servicename: UILabel!
    
    @IBOutlet weak var hour: UILabel!
    
    @IBOutlet weak var eventposter: UIImageView!
    
    @IBOutlet weak var eventtitle: UILabel!
    
    @IBOutlet weak var backdrop: UIImageView!
    @IBOutlet weak var servicelogo: UIImageView!
    
    @IBOutlet weak var eventdescription: UILabel!
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            var d = tableView.dequeueReusableCell(withIdentifier: "nowcell") as! NowTableViewCell
            d.setup(e: self.now ?? EpgEvent())
            return d;
        }
        
        if indexPath.row == 1{
        var d = tableView.dequeueReusableCell(withIdentifier: "nextlabel")
            return d!;
        }
        
        
        var d = tableView.dequeueReusableCell(withIdentifier: "nextcell") as! NextTableViewCell
      
        if let event = self.events?[indexPath.row - 2] {
            d.setup(e: event)
        }
        return d;

        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        context.nextFocusedItem
    }
    
    @IBAction func backPressed(_ sender: Any) {
         NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: "hidePip"), object: [String:Any](), userInfo: ["direction":0])
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    var events:[EpgEvent]?
    var pindexPath = IndexPath(row: -1, section: 0);
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = context.nextFocusedIndexPath else {return}
        if pindexPath.row == indexPath.row {return}
        pindexPath.row = indexPath.row
        self.backdrop.image=nil
        self.eventtitle.text = ""
       self.eventdescription.text = ""
       self.hour.text = ""
        self.eventposter.image = nil
   
        var event:EpgEvent?
        if let row = tableView.cellForRow(at: indexPath) as? NowTableViewCell{
            event = self.now
        }
        if let row = tableView.cellForRow(at: indexPath) as? NextTableViewCell{
            event = self.events?[indexPath.row-2]
        }
        if let event = event{
            self.event = event
            self.eventtitle.text = event.title
            self.eventdescription.text = event.longdesc
            self.hour.text = event.getBeginTimeString()
            
            
            STBAPI.common()?.searchInfoWeb(title: event.title!, duration: Int(event.duration_sec!/60), eid: Int(event.begin_timestamp!) ) {
                image, backdrop, eid, ok in
                if eid != Int(self.event!.begin_timestamp!) {return}
                DispatchQueue.main.sync {
                    if (ok ){
                        if (backdrop != nil){
                            self.backdrop.image = backdrop//image
                        }
                        
                            if (image != nil){
                                self.eventposter.image = image//image
                                
                            }
                        
                        
                    }
                
                }
            }
            
            
            
           
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //guard let indexPath = context.nextFocusedIndexPath else {return}
        var event_:EpgEvent?
        var showWatchnow=false;
        var showRecord=false;
        if let row = tableView.cellForRow(at: indexPath) as? NowTableViewCell{
            showWatchnow = true
            event_ = row.event
        }
        if let row = tableView.cellForRow(at: indexPath) as? NextTableViewCell{
            event_ = row.event
            showRecord = true
        }
        guard let event = event_ else {return}
        
        let alert = UIAlertController(title: event.title!, message: event.shortdesc, preferredStyle: .actionSheet)
                if showWatchnow{
                    alert.addAction(UIAlertAction(title: "Watch Channel Now", style: .default){ a in
                       alert.dismiss(animated: true, completion: nil)
                       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPlayed"), object: ["service":self.service,"bouquet":self.bouquet!])
                    })
                    alert.addAction(UIAlertAction(title: "Watch Channel as Picture in Picture", style: .default){ a in
                       alert.dismiss(animated: true, completion: nil)
                       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismiss"), object: ["service":self.service,"bouquet":self.bouquet!])
                    })
                }
            if showRecord{
             alert.addAction(UIAlertAction(title: "Schedule recording", style: .default){ a in
                 STBAPI.common()?.setTimer(sref: event.sref!, eid: Int(event.id!)){x in
                 }
             })
            alert.addAction(UIAlertAction(title: "Schedule notificatoin", style: .default){ a in
                //STBAPI.common()?.setTimer(sref: event.sref!, eid: Int(event.id!)){x in
                //}
            })
            }
             alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){ a in
                 
             })
             self .present(alert, animated: true, completion: {})
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            
            return 300
        }
        return 66
    }
    
 
    
    @IBOutlet weak var tv: UITableView!
    
    
    @IBAction func watchnow(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPlayed"), object: ["service":service!, "bouquet":bouquet!], userInfo: ["direction":0])
    }
    
    
    
    @IBAction func watchpip(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pipPlayed"), object: ["service":service!, "bouquet":bouquet!], userInfo: ["direction":0])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
            
        
        // Do any additional setup after loading the view.
    }
    
    func setup(){
        if let s = self.servicename{
            s.text = self.service?.servicename ?? ""
            if let logo = service?.getLogoURL(){
                self.servicelogo.sd_setImage(with: logo, completed: nil)
            }
        }
        
    }
    func configure(s:Service,b:Service,e:EpgEvent){
        self.bouquet = b
        self.service = s
        self.event = e
        self.now = e
        STBAPI.common()?.getFullEPG(for: self.service!, from: e.end_timestamp! , to: e.end_timestamp!+100000){events, service in
                       DispatchQueue.main.async {
                           self.events = events
                           self.tv.reloadData()
                       }
                   }
        setup()
    }


    

}
