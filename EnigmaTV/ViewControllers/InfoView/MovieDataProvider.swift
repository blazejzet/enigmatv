//
//  EventDataProvider.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 25.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

class MovieDataProvider: InfoViewDataProviderDelegate {
    
    weak var mp : VLCMediaPlayer?
    var movie:Movie?
    
    public func refresh(){
        
        // position zmienia się?... zostaje stałe przy pauzie, mimo, że zmienia się czas nagrania... aha... to trzeba obejść jakoś...
        
        
    }
    
    func getServiceName() -> String {
        //self.refresh()
        return movie!.servicename!
    }
    func getRecordingTimeX(movie:Movie)->Int{
        let s:String = movie.length!
        let c = s.components(separatedBy: ":")
        if c.count>=2{
            let i = 50*Int(c[0])!+Int(c[1])!
            return i
        }
        return 0
        
    }
    func getCurrentEvent() -> EpgEventCacheProtocol? {
        let x = EpgEventCache(context: DataProvider.def().context)
        x.begin_timestamp = 0
        
        x.dudation_sec =  Int64(UInt64(getRecordingTimeX(movie: movie!)))
        x.sname = movie?.servicename
        x.tilte = movie?.eventname
        
        //self.refresh()
        return x//movie.getEvent()
    }
    
    func getNextEvent() -> EpgEventCacheProtocol? {
        //self.refresh()
        return nil
    }
    
    func getCurrentTime() -> UInt64 {
        //self.refresh()
        //czas aktualnego oglądania...
        return UInt64(mp!.position * Float(getRecordingTimeX(movie: movie!)))
    }
    
    func getRealTime() -> UInt64 {
        //self.refresh()
        return UInt64(Date().timeIntervalSince1970)
    }
    
    func getTimeshiftStartTime() -> UInt64 {
        //self.refresh()
        return 0
    }
    
    func getTimeshiftStopTime() -> UInt64 {
        //self.refresh()
        return UInt64(getRecordingTimeX(movie: movie!))
    }
    
    func shouldDisplayTimeshiftInfo() -> Bool {
        //self.refresh()
        return true
    }
    
    func jumpTo(_ time:UInt64){
        print("Current player time: \(mp!.time.intValue)")
        print("sent time: \(time)")
        let duration = UInt64(getRecordingTimeX(movie: movie!))
        _ =  UInt64(Float((mp?.position)!) * Float(duration))
        let new_mptime = time
        
        var procent = Float(new_mptime) / Float(duration)
        
        if procent>0.98{
            procent = 0.98
        }
        if procent<0.001{
            procent = 0.001
        }
        
        mp?.position=procent
        
        
        
    }
    
}


