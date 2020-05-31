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
     var nexturl:URL?
    var v1:UIView!
    var v2:UIView!
    
    
    var first : (UIView,VLCMediaPlayer)!
    var second : (UIView,VLCMediaPlayer)!
          
    //var timer: Timer?//
    
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        //print(first.1.media?.metaDictionary)
        if(VLCMediaPlayerState.buffering == first.1.state ){ print("[STATE] VLCMediaPlayerState.buffering \( VLCMediaPlayerState.buffering == first.1.state )")}
        if(VLCMediaPlayerState.ended == first.1.state ){ print("[STATE] VLCMediaPlayerState.ended \( VLCMediaPlayerState.ended == first.1.state )")}
        if(VLCMediaPlayerState.error == first.1.state ){ print("[STATE] VLCMediaPlayerState.error \( VLCMediaPlayerState.error == first.1.state )")}
        if(VLCMediaPlayerState.esAdded == first.1.state ){ print("[STATE] VLCMediaPlayerState.esAdded \( VLCMediaPlayerState.esAdded == first.1.state )")}
        if(VLCMediaPlayerState.opening == first.1.state ){ print("[STATE] VLCMediaPlayerState.opening \( VLCMediaPlayerState.opening == first.1.state )")}
        if(VLCMediaPlayerState.playing == first.1.state ){ print("[STATE] VLCMediaPlayerState.playing \( VLCMediaPlayerState.playing == first.1.state )")}
        if(VLCMediaPlayerState.paused == first.1.state ){ print("[STATE] VLCMediaPlayerState.paused \( VLCMediaPlayerState.paused == first.1.state )")}
        if(VLCMediaPlayerState.stopped == first.1.state ){ print("[STATE] VLCMediaPlayerState.stopped \( VLCMediaPlayerState.stopped == first.1.state )")}
      
//        print("[STATE] VLCMediaPlayerState ============")
        
        //print(aNotification)
        //print(first.1.state.rawValue)
        if(first.1.state == VLCMediaPlayerState.buffering){
            
            self.perform(#selector(StreamView.showMe), with: nil, afterDelay: 5.0)
        }
        
        if(first.1.state == VLCMediaPlayerState.playing){
            self.showMe();
        }
        
        if (VLCMediaPlayerState.stopped == first.1.state){
            first.1.play()
        }
        if (VLCMediaPlayerState.ended == first.1.state){
            first.1.play()
        }
        
     }
    
    @objc func showMe(){
        print("showing");
        UIView.animate(withDuration: 0.3){
            //self.alpha=1.0
        }
    }
    
    var mp:VLCMediaPlayer!
    var mp2:VLCMediaPlayer!
    
    var timer:Timer?
    var timerVA:Timer?
    var cdelay = 0
    init() {
        super.init(frame:CGRect(x: 0, y: 0, width: 1920 , height: 1080));
        //self.first.1.play()
               v1 = UIView(frame: self.frame)
               v2 = UIView(frame: CGRect(x: 60, y: 60, width: 480, height: 270))
               self.addSubview(v1)
               self.addSubview(v2)
        
        if mp == nil {
         mp = VLCMediaPlayer()
         mp.drawable = v1
         //first.1.delegate = self
        }
        if mp2 == nil {
         mp2 = VLCMediaPlayer()
         mp2.drawable = v2
         //first.1.delegate = self
        }
        
        first = (v1!,mp!)
        second = (v2!,mp2!)
        
       // timerVA = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){_ in
           // print("VA: \( self.first.1.media?.metadata(forKey: "title") )")
           // print("VA: \( self.first.1.media?.metaDictionary )")
           //x§ print("VA: \( self.first.1.media?.stats )")
            
        //}
        /*
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
        
         //self.cdelay = Int(1000000*(-delay))
        //print ("         latency: \(self.cdelay)");
        //print ("    Latenyc is set: \(self.first.1.currentAudioPlaybackDelay)");
       // if (self.first.1.currentAudioPlaybackDelay !=  self.cdelay){
            
           // self.first.1.play()
            ///self.first.1.currentAudioPlaybackDelay = self.cdelay
            
            // print ("  already is set: \(self.first.1.currentAudioPlaybackDelay)");
        //}
           // self.first.1.delay
        
        //}else{
        //
        
        //}
        }
 */
    }
   
    
    func getLastService(cb:@escaping (Service?,Service?)->Void){
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
        first.1.stop()
        first.1.media = nil
        first.1.delegate = self
    }
    
    
    var changeToPosition:Float?
    var timeshift = false;
    @objc func switchToTimeshift(){
        let furl = TimeShiftRecorder.common().fileurl
        first.1.media = VLCMedia(url: furl!)
        first.1.drawable = self;
       
        //self.changeToPosition=0.9
        //first.1.play();
       timeshift = true
       // first.1.jumpForward(Int32(TimeShiftRecorder.common().getIntervalsinceBeginning()))
       
    }
    
    
    
    
    
    func stTogglePause(){
        if let mp = mp{
            if (first.1.isPlaying){
            self.stpause()
        }else{
            self.stplay()
            }
            
        }
    }
    func stpause(){
        first.1.pause()
    }
    func stplay()
    {
        first.1.play()
    }
    
    func playLiveStream(){
        timeshift = false;
        var nurl = VLCMedia(url: url!)
        if (second.1.media.url == nurl.url ){
            (first,second)=(second,first)
            first.1.delegate = self
            second.1.delegate = nil
            
            
            UIView.animate(withDuration: 0.3){
                self.first.0.frame = self.frame
                self.second.0.frame = CGRect(x: 60, y: 60, width: 480, height: 270)
                
            }
            self.bringSubview(toFront: self.second.0)
            
            second.1.stop()
            
        }else{
            first.1.media = nurl
            first.1.drawable = v1;
            first.1.play();
        }
        
    }
    
    var mode = viewingMode.service
    
    func prepare(_ service:Service, inBouquet bouquet:Service){
        self.prepareForStream(ref: service.servicereference!)
        self.prepareLiveStream()
    }
    func play(_ service:Service, inBouquet bouquet:Service){
        mode = viewingMode.service
        self.saveLast(service: service, bouquet: bouquet)
        //first.1.pause()
        
        if (STBAPI.common()!.zap){
            STBAPI.common()?.zap(for: service)
        }
        self.prepareStream(ref: service.servicereference!)
        
        if (mode == .service &&
            (STBAPI.common()?.timeshift)!){
            self.startTimeshift(url: url!,service:service, inBouquet:bouquet)
            //self.switchToTimeshift()
           
            
            }else{
            //self.playLiveStream()
                //self.perform(#selector(StreamView.showMe), with: nil, afterDelay: 2.0)
                
            }
            self.playLiveStream()
        }
    
    public func receivedFirstData(){
        //Wiem że już są dane z TS. Mogę to zaznaczyć na
        //
        print("FD")
        //self.perform(#selector(StreamView.switchToTimeshift), with: nil, afterDelay: 0.4)
        //self.perform(#selector(StreamView.showMe), with: nil, afterDelay: 0.4)
        
    }
    
    func skipto(p:Float){
        self.first.1.position=p
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
        //self.perform(#selector(StreamView.showMe), with: nil, afterDelay: 2.0)
        }
    }
    
    
    func startTimeshift(url:URL,service:Service, inBouquet bouquet:Service)->URL{
        if (mode == .service){
        TimeShiftRecorder.common().delegate=self
        return TimeShiftRecorder.common().startTimeShift(for: url,service:service, inBouquet:bouquet)
        }
        else {
            return url
        }
    }
    
    func prepareForStream(ref:String, saveLast:Bool = true, full:Bool = false){
        var urlstring:String?
        if (!full){
             urlstring =  STBAPI.common()?.urlForRef(ref);
        }else{
            urlstring = ref
        }
        nexturl = URL(string:urlstring!)!
        
        
       }
    func prepareLiveStream(){
       // timeshift = false;
        second.1.media = VLCMedia(url:  nexturl!)
    
        second.1.play();
       //
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
        
        
        self.isUserInteractionEnabled=true
       
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
       
        
    }
    
    
    
    //TO JSON
    private func saveLast(service:Service, bouquet:Service){
        
        do{
            
            UserDefaults.standard.set(service.servicereference!, forKey: "lastService");
            UserDefaults.standard.set(bouquet.servicereference!, forKey: "lastBouquet");
            UserDefaults.standard.synchronize()
        }catch{
            print("Problems with JSON ENCODING")
        }
        
        
        
    }
    private func getLastStream(cb:@escaping (Service?,Service?)->Void){
        let sref = UserDefaults.standard.string(forKey: "lastService")
        let bref = UserDefaults.standard.string(forKey: "lastBouquet")
        
            if let brefd = bref{
                DataProvider.def().getBouquet(bref: brefd){
                    Service in
                    if let srefd = sref{
                        DataProvider.def().getService(bref: brefd, sref: srefd){
                            Service in
                            cb(Service,Service)
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
