//
//  ViewController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import CloudKit


extension UIViewController{
    func dismissAllVC(){
     self.presentedViewController?.dismissAllVC()
     self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}


class ViewController: UIViewController {
    var sv:StreamView?
    
    @IBOutlet weak var finfo: UILabel!
    @IBOutlet weak var hudView: UIView!
    
    @IBOutlet weak var tvView: UIView!
    
    var dvc : UIViewController?
    
    @objc func dismissVC(notification:NSNotification){
        print("play movie");
        //print(dvc);
        let dvc = self.dvc;
        dvc?.dismiss(animated: true, completion: {
            dvc?.dismiss(animated: true, completion: nil)
        });
        if let movie = notification.object as? Movie{
            self.watchMovie(movie)
        }
        
    }
    @objc func dismissVCCont(notification:NSNotification){
        print("play movie");
        //print(dvc);
        let dvc = self.dvc;
        dvc?.dismiss(animated: true, completion: {
            dvc?.dismiss(animated: true, completion: nil)
        });
        if let movie = notification.object as? Movie{
            self.continueMovie(movie)
            
            
            
        }
        
    }
    @objc func bouquetPlayed(notification:NSNotification){
        print("play stream");
        let dvc = self.dvc;
        dvc?.dismiss(animated: true, completion: {
            dvc?.dismiss(animated: true, completion: nil)
        });
        if let dict = notification.object as? [String:Any]{
           if let bouquet = dict["bouquet"] as? EpgBouquet, let service = dict["service"] as? EpgService{
            print(dict)
                self.watch(service, inBouquet: bouquet)
            }
            
        }
        
    }
    
    
    
    @objc func rfinfo(){
        DispatchQueue.main.async {
        UIView.animate(withDuration: 0.3, animations: {
            self.finfo.alpha=0.0
        })
        }
    }
    func sfinfo(){
        DispatchQueue.main.async {
        UIView.animate(withDuration: 0.3, animations: {
            self.finfo.alpha=1.0
        })
        }
        self.perform(#selector(ViewController.rfinfo), with: nil, afterDelay: 5.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //EPGHelper.showAll(text: "VC")
        
        //EPGHelper.preloadingEPG()
        EPGHelper.getInstance()?.displayall(text: "VC");
        
        self.perform(#selector(ViewController.rfinfo), with: nil, afterDelay: 5.0)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.dismissVC(notification:)), name: NSNotification.Name(rawValue: "moviePlayed"), object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.dismissVCCont(notification:)), name: NSNotification.Name(rawValue: "movieContinue"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.bouquetPlayed(notification:)), name: NSNotification.Name(rawValue: "bouquetPlayed"), object: nil);
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        sv = StreamView();
        self.tvView.addSubview(sv!);
        
       /* var g = UITapGestureRecognizer(target: self, action: #selector(ViewController.epgTapped))
        g.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
        sv?.addGestureRecognizer(g)*/
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
    }
    
    @objc func checkSettings(){
        if self.refreshonload{
            STBAPI.restart();
            self.refreshonload = false
            self.restartPlayer();
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       print("V APPEARED");
        
        
        self.restartPlayer();
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "tuner.setupready"), object: nil, queue: nil, using: {_ in
            print("SETUP DONE")
            self.dismissAllVC()
            self.restartPlayer();
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "tuner.manualsetup"), object: nil, queue: nil, using: {_ in
            print("SETUP MANUALLY")
            self.dismissAllVC()
            self.refreshonload=true;
        })
    }
    var refreshonload = false;
    
    func restartPlayer(){
        STBAPI.common()?.test(success:{ tunerinfo in
            self.start()
            self.perform(#selector(ViewController.tapMenu(_:)), with: self, afterDelay: 1.0)
        },
                              failure:{
                                //trzeba zrobić analizę sieci
                                self.performSegue(withIdentifier: "showsettings", sender: self)
                                
                                
        })
    }
    
    override func viewWillLayoutSubviews() {
        //print("V LS");
        // sv?.playStream(ref: "1:0:19:1F4:1C37:17B8:FFFF0000:0:0:0:");
        //sv?.playLastStream()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stop()
    }
    func stop(){
        sv?.stop()
        
    }
    
    @objc func start(){
        sv?.getLastService{ service, bouquet in
            if let service = service, let bouquet = bouquet {
                self.watch(service, inBouquet: bouquet)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var  privateCloudDatabase:CKDatabase?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let movie = self.watching as? Movie{
            let x = (sv?.mp?.position)
            if let x = x{
                let y = Int(x*100.0)
                let myContainer = CKContainer.default()
                self.privateCloudDatabase = myContainer.privateCloudDatabase
                let id = CKRecordID(recordName: movie.serviceref!)
                //let predicate = NSPredicate(value: true)
                //let query = CKQuery(recordType: "MovieInfo", predicate: predicate)
                privateCloudDatabase?.fetch(withRecordID: id, completionHandler: {(r,_ ) in
                    if let r = r {
                        var n  = NSNumber(integerLiteral: y)
                        print("updating time to : \(n)")
                        r["watched"] = n
                        self.privateCloudDatabase?.save(r) { e, error in
                            print(error)
                            print(e)
                        }
                    }
                })
                
            }
        }
        
        self.dvc = segue.destination
        if let evc = segue.destination as? InfoViewController
        {//jeśli pokazujemy informacje...
            if let movie = self.watching as? Movie{
                // w przypadku filmu z nagrań.
                var dp = MovieDataProvider()
                dp.movie = movie
                dp.mp = sv?.mp
                evc.delegate = self
                evc.edp = dp
            }
            if let service = self.watching as? Service{
                // w przypadku programu live
                if (sv?.timeshift)!{
                    //jeśli timeshift aktywny
                    var tsdp = TimeshiftDataProvider()
                    tsdp.mp = sv?.mp
                    tsdp.refresh()
                    evc.delegate=self
                    evc.edp = tsdp
                }else{
                    //jeśli tmieshift nieaktywny
                    evc.delegate=self
                    STBAPI.common()?.nowPlaying(at:service.servicereference!){
                        nowE, nextE in
                        let edp = EventDataProvider()
                        edp.event = nowE
                        edp.nextevent = nextE
                        evc.edp = edp
                    }
                }
            }
        }
        
        
        
        
        
        
        if let evc = segue.destination as? EPGViewController{
            evc.delegate = self
        }
        
    }
        
        
        
    
    
    var watching:Any?
    var bouquet:EpgBouquet?
    var services:[EpgService]?
   // var subservices:Servicelist?
    
    func watch(_ service:EpgService, inBouquet bouquet:EpgBouquet, dir:Direction = .Center){
        self.switchChannel(dir)
        self.bouquet = bouquet
        self.watching = service
       // if ((bouquet.sname) == (self.bouquet?.sname)){
                //existing service
            sv?.play(service, inBouquet:bouquet)
            self.perform(#selector(ViewController.showInfoService), with: nil, afterDelay: 1.0)
        /*}else{
            self.bouquet = bouquet
            /*STBAPI.common()?.getServices(for: bouquet,cb:{
                list in
                self.subservices = list
                self.sv?.play(service, inBouquet:bouquet)
                self.perform(#selector(ViewController.showInfoService), with: nil, afterDelay: 1.0)
            },fail:{
                self.finfo.text="Error"
                self.sfinfo()
            })*/
            DataProvider.def().getServices(bref: bouquet.sref!){
                services in
                self.services = services
                self.sv?.play(service, inBouquet:bouquet)
                self.perform(#selector(ViewController.showInfoService), with: nil, afterDelay: 1.0)
            }
            */
        
        
    }
    func watchMovie(_ movie:Movie){
        self.watching = movie
        self.bouquet=nil
        sv?.play(movie)
        showInfo(for: movie)
    }
    func continueMovie(_ movie:Movie){
        self.watching = movie
        self.bouquet=nil
        sv?.play(movie)
        showInfo(for: movie)
        
        let myContainer = CKContainer.default()
        self.privateCloudDatabase = myContainer.privateCloudDatabase
        let id = CKRecordID(recordName: movie.serviceref!)
        
        privateCloudDatabase?.fetch(withRecordID: id, completionHandler: {(r,_ ) in
            if let r = r {
                //var n  = NSNumber(integerLiteral: y)
                var n = r["watched"] as? NSNumber
                if let i = n?.intValue{
                    var perc =  Float(i)/100.0
                    self.sv?.skipto(p:perc)
                }
            }
        })
        
    }
    
    @objc func showInfoService(){
        self.showInfo(for: watching!)
    }
    
    func showInfo(for media:Any){
           self.performSegue(withIdentifier: "info", sender: media)
       }

    func showChooser(for media:Any){
           self.performSegue(withIdentifier: "chooser", sender: media)
       }
       
    
    @IBAction func tapRight(_ sender: Any) {
        if let service = watching as? Service{
            if var row =  service.row{
                if let list = services{
                    row = row + 1
                    if (row>=list.count){
                        row=0
                    }
                    let newservice = list[row]
                    print("switching to \(row)")
                    
                    self.watch(newservice, inBouquet: self.bouquet!, dir: .Left)
                }
            }
        }
        print("tap right")
        
    }
    @IBAction func tapLeft(_ sender: Any) {
        print("tap left")
        if let service = watching as? Service{
            if var row =  service.row{
                if let list = services{
                    row = row - 1
                    if (row<0){
                        row=list.count-1
                    }
                    print("switching to \(row)")
                    let newservice = list[row]
                    
                    self.watch(newservice, inBouquet: self.bouquet!, dir: .Right)
                }
            }
        }
    }
    
    func switchChannel(_ dir:Direction){
        DispatchQueue.main.async{
        UIView.animate(withDuration: 0.3, animations: {
            if dir == Direction.Left{
                self.sv?.center=CGPoint(x:0,y:540)
            }
            if dir == Direction.Right{
                self.sv?.center=CGPoint(x:1920,y:540)
            }
            if dir == Direction.Center{
                self.sv?.center=CGPoint(x:1920.0/2.0,y:540.0)
            }
            self.sv?.alpha=0.0
        }, completion: {_ in
            self.sv?.center=CGPoint(x:1920.0/2.0,y:540)
        })
        }
        
    }
    
    var menulock = true
    @IBAction func tapMenu(_ sender: Any) {
        if menulock {
            menulock = false
            self.performSegue(withIdentifier: "epg", sender: sender)
            self.perform(#selector(ViewController.menuUnlock), with: nil, afterDelay: 4.0)
        }else{
            exit(EXIT_SUCCESS)
        }
    }
    @objc func menuUnlock(){
        menulock = true
    }
    //PILOt
    
    @IBAction func playPausePressed(_ sender: Any) {
        //if (sv?.timeshift)!{
            sv?.stTogglePause()
        //}else{
        //    sv?.switchToTimeshift()
            //sv?.stpause()
        //}
        //switching to timeShift
    }
    

}



enum Direction{
    case Left,Right,Center
}
