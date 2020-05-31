//
//  EventDataProvider.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 25.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

class TimeshiftDataProvider: InfoViewDataProviderDelegate {
    
   
    weak var ts : TimeShiftRecorder?
    weak var mp : VLCMediaPlayer?
    var ct:UInt64?
    var event:EpgEvent?
    var nextevent:EpgEvent?
    
    public func refresh(){
        ts = TimeShiftRecorder.common()
        self.nextevent = nil
        self.event = nil
        // position zmienia się?... zostaje stałe przy pauzie, mimo, że zmienia się czas nagrania... aha... to trzeba obejść jakoś...
        var mptime =  UInt64(Float((mp?.position)!) * Float(Date().timeIntervalSince1970 - (ts?.timestart)!))
        
       // print("mp:\(mp!), time :\(mptime)")
        ct = UInt64((ts?.timestart)!) + mptime
       // print("ct:\(ct!)")
        if let events = ts?.events{
            var i = 0;
            for e in events{
                if (e.begin_timestamp! <= ct! && e.begin_timestamp! + e.duration_sec! >= ct!){
                    if (self.event == nil) {
                        self.event = e
                    i=1;
                        
                    }

                    
                }
                if (e.begin_timestamp! >= ct! ){
                        if (self.nextevent == nil) {
                           
                            self.nextevent = e
                        }
                    }
                    
                
            }
        }
        
    }
    
    func getServiceName() -> String {
        //self.refresh()
        if let l =  event?.sname {
            return l
        }
        return ""
    }
    func getCurrentEvent() -> EpgEvent? {
        //self.refresh()
        return event
    }
    
    func getNextEvent() -> EpgEvent? {
        //self.refresh()
        return nextevent
    }
    
    func getCurrentTime() -> UInt64 {
        //self.refresh()
        //czas aktualnego oglądania...
        return ct!
    }
    
    func getRealTime() -> UInt64 {
        //self.refresh()
        return UInt64(Date().timeIntervalSince1970)
    }
    
    func getTimeshiftStartTime() -> UInt64 {
        //self.refresh()
        return UInt64((ts?.timestart!)!)
    }
    
    func getTimeshiftStopTime() -> UInt64 {
        //self.refresh()
        return UInt64(Date().timeIntervalSince1970)
    }
    
    func shouldDisplayTimeshiftInfo() -> Bool {
        //self.refresh()
        return true
    }
    
    func jumpTo(_ time:UInt64){
        print("Current player time: \(mp!.time.intValue)")
        print("sent time: \(time)")
        var duration = Float(Date().timeIntervalSince1970 - (ts?.timestart)!)
        var mptime =  UInt64(Float((mp?.position)!) * duration)
        
        print("mp:\(mp), time :\(mptime)")
        var current_time = UInt64((ts?.timestart)!) + mptime
        var new_mptime = time - UInt64((ts?.timestart)!)
        print("ct:\(current_time), new_time :\(time)")
        print("ctmpt:\(mptime), new_mptime :\(new_mptime)")
        
        
        //var duration = Float(Date().timeIntervalSince1970) - Float((ts?.timestart)!)
        
        var procent = Float(new_mptime) / duration
        print("Jumping to: \(procent)")
        
        if procent>0.98{
            procent = 0.98
        }
        if procent<0.001{
            procent = 0.001
        }
        
        mp?.position=procent
        
        print("pos\(mp?.position)")
        
        
        }
    
}

