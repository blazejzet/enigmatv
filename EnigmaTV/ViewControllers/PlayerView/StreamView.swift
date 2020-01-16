//
//  StreamView.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

import Pods_EnigmaTV
import CloudKit
import AVFoundation
import CoreFoundation

class StreamView: UIView, VLCMediaPlayerDelegate {

    
    var url:URL?
    
    
    //var timer: Timer?//
    
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        print(mp?.media?.metaDictionary)
        print("------------ !!!! META CHANGED")
        
        //print(aNotification)
        //print(mp?.state.rawValue)
        if(mp?.state == VLCMediaPlayerState.buffering){
            
            self.perform(#selector(StreamView.showMe), with: nil, afterDelay: 2.0)
        }
        
     }
    
    @objc func showMe(){
        if let ch = changeToPosition{
            mp?.position = ch
            print("delayed chagnge to \(ch)")
            changeToPosition=nil
            mp?.pause()
        }
        UIView.animate(withDuration: 0.3){
            self.alpha=1.0
        }
    }
    
    var mp:VLCMediaPlayer?
    
    var timer:Timer?
    var timerVA:Timer?
    var cdelay = 0
    init() {
        super.init(frame:CGRect(x: 0, y: 0, width: 1920 , height: 1080));
        timerVA = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){_ in
           // print("VA: \( self.mp?.media?.metadata(forKey: "title") )")
           // print("VA: \( self.mp?.media?.metaDictionary )")
           //x§ print("VA: \( self.mp?.media?.stats )")
            
        }
        
       timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true){_ in
            let currentRoute = AVAudioSession.sharedInstance().currentRoute
       //().set
        
        self.cdelay = 0
        print("Latency: \(AVAudioSession.sharedInstance().outputLatency)")
            var delay = 0.0;
            if currentRoute.outputs != nil {
                for description in currentRoute.outputs {
                    switch description.portType {
                    case AVAudioSessionPortAirPlay:
                        delay = AVAudioSession.sharedInstance().outputLatency;
                        print ("adjusting latency: \(delay)");
                        if let d = STBAPI.common()?.getDelay(){
                        print ("      adjusting d: \(d)");
                        delay = delay-d;
                        print ("adjusting latency: \(delay)");
                        }
                       
                    
                    default:
                        delay = AVAudioSession.sharedInstance().outputLatency;
                    }
                }
            }
        
         self.cdelay = Int(1000000*(-delay))
        print ("         latency: \(self.cdelay)");
        print ("    Latenyc is set: \(self.mp?.currentAudioPlaybackDelay)");
        if (self.mp?.currentAudioPlaybackDelay !=  self.cdelay){
            
            self.mp?.play()
            self.mp?.currentAudioPlaybackDelay = self.cdelay
            
             print ("  already is set: \(self.mp?.currentAudioPlaybackDelay)");
        }
           // self.mp?.delay
        
        //}else{
        //
        
        //}
        }
 
    }
   
    
    func getLastService(cb:@escaping (EpgService?,EpgBouquet?)->Void){
        getLastStream {service,bouquet in
            if let service = service {
                cb(service,bouquet)
            }else{
                cb(nil,nil)
            }
        }
        
    }
    
    
    func stop(){
        timeshift = false;

        print("Stopping stream")
        TimeShiftRecorder.common().stop()
        mp?.stop()
        mp?.media = nil
        mp?.delegate = self
    }
    
    
    var changeToPosition:Float?
    var timeshift = false;
    @objc func switchToTimeshift(){
        let furl = TimeShiftRecorder.common().fileurl
        mp?.media = VLCMedia(url: furl!)
        mp?.drawable = self;
       
        //self.changeToPosition=0.9
         mp?.play();
       timeshift = true
       // mp?.jumpForward(Int32(TimeShiftRecorder.common().getIntervalsinceBeginning()))
       
    }
    
    
    
    
    func stTogglePause(){
        if let mp = mp{
        if (mp.isPlaying){
            self.stpause()
        }else{
            self.stplay()
            }
            
        }
    }
    func stpause(){
        mp?.pause()
    }
    func stplay()
    {
        mp?.play()
    }
    
    func playLiveStream(){
        timeshift = false;
        mp?.media = VLCMedia(url: url!)
        mp?.drawable = self;
        mp?.play();
    }
    
    var mode = viewingMode.service
    func play(_ service:EpgService, inBouquet bouquet:EpgBouquet){
        mode = viewingMode.service
        self.saveLast(service: service, bouquet: bouquet)
        
        
        if (STBAPI.common()!.zap){
            STBAPI.common()?.zap(for: service)
        }
        self.prepareStream(ref: service.sref!)
        
        if (mode == .service &&
            (STBAPI.common()?.timeshift)!){
            self.startTimeshift(url: url!,service:service, inBouquet:bouquet)
            //self.switchToTimeshift()
            self.perform(#selector(StreamView.switchToTimeshift), with: nil, afterDelay: 3.0)
            self.perform(#selector(StreamView.showMe), with: nil, afterDelay: 4.0)
            
        }else{
            self.playLiveStream()
            self.perform(#selector(StreamView.showMe), with: nil, afterDelay: 2.0)
            
        }
    }
    
    func skipto(p:Float){
        self.mp?.position=p
    }
    
    func play(_ movie:Movie){
        mode = .movie
        let ref = movie.serviceref!
        let ref3 = ref.components(separatedBy: .init(charactersIn: ":")).last
        let urlb = ref3!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)?.replacingOccurrences(of: "+", with: "%2B")
        if let x = STBAPI.common()?.stbURL {
        let urlbstr = "\(x)/file?file=\(urlb!)"
        
            
            let myContainer = CKContainer.default()
            let privateCloudDatabase = myContainer.privateCloudDatabase
            let movieInfo = CKRecord(recordType: "MovieInfo", recordID: CKRecordID(recordName: movie.serviceref!))
            movieInfo["ind"] = NSNumber(integerLiteral: 0)
            movieInfo["watched"] = NSNumber(integerLiteral: 0)
            privateCloudDatabase.save(movieInfo, completionHandler: {ckrek,_ in
                
                print(ckrek)
            })

            
            
            
            
//        let urlbstr = urlb)
        
        
        //http://10.0.0.38/web/ts.m3u?
        //file=/hdd/movie/20180201%200750%20-
        //%20Canal%20+%20HD%20-%20Bardzo%20fajny%20gigant.ts
        
        //http://10.0.0.38/web/ts.m3u?
        //file=/hdd/movie/20180201%200750%20-
        //%20Canal%20%2B%20HD%20-%20Bardzo%20fajny%20gigant.ts
        //http://10.0.0.38/web/ts.m3u?file=/hdd/movie/20180201%200750%20-%20Canal%20+%20HD%20-%20Bardzo%20fajny%20gigant.ts
        
        let ref2 = ref.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlUserAllowed)
        self.prepareStream(ref: urlbstr, saveLast: false, full:true);
        self.playLiveStream()
        self.perform(#selector(StreamView.showMe), with: nil, afterDelay: 2.0)
        }
    }
    
    
    func startTimeshift(url:URL,service:EpgService, inBouquet bouquet:EpgBouquet)->URL{
        if (mode == .service){
        TimeShiftRecorder.common().delegate=self
        return TimeShiftRecorder.common().startTimeShift(for: url,service:service, inBouquet:bouquet)
        }
        else {
            return url
        }
    }
    
    func prepareStream(ref:String, saveLast:Bool = true, full:Bool = false){
        var urlstring:String?
        if (!full){
             urlstring =  STBAPI.common()?.urlForRef(ref);
        }else{
            urlstring = ref
        }
        url = URL(string:urlstring!)!
        print("prepared \(urlstring)");
        if mp == nil {
             mp = VLCMediaPlayer()
             mp?.delegate = self
        }
        
        self.isUserInteractionEnabled=true
       
        
    }
    
    public func receivedFirstData(){
        //Wiem że już są dane z TS. Mogę to zaznaczyć na
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    
    
    //TO JSON
    private func saveLast(service:EpgService, bouquet:EpgBouquet){
        
        do{
            
            UserDefaults.standard.set(service.sref, forKey: "lastService");
            UserDefaults.standard.set(bouquet.sref, forKey: "lastBouquet");
            UserDefaults.standard.synchronize()
        }catch{
            print("Problems with JSON ENCODING")
        }
        
        
        
    }
    private func getLastStream(cb:@escaping (EpgService?,EpgBouquet?)->Void){
        let sref = UserDefaults.standard.string(forKey: "lastService")
        let bref = UserDefaults.standard.string(forKey: "lastBouquet")
        
            if let brefd = bref{
                DataProvider.def().getBouquet(bref: brefd){
                    epgBouquet in
                    if let srefd = sref{
                        DataProvider.def().getService(bref: brefd, sref: srefd){
                            epgService in
                            cb(epgService,epgBouquet)
                        }
                    }else{
                        cb(nil,nil)
                    }
                }
            }else{
                cb(nil,nil)
            }
            
            
        
    }
    
}


enum viewingMode{
    case movie,service
}
