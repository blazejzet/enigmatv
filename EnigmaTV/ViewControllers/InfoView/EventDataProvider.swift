//
//  EventDataProvider.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 25.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

class EventDataProvider: InfoViewDataProviderDelegate {
    var event:EpgEventCache?
    var nextevent:EpgEventCache?
    
    func getServiceName() -> String {
        return (event?.sname)!
    }
    func getCurrentEvent() -> EpgEventCache? {
        return event
    }
    
    func getNextEvent() -> EpgEventCache? {
        return nextevent
    }
    
    func getCurrentTime() -> UInt64 {
        return UInt64(Date().timeIntervalSince1970)
    }
    
    func getRealTime() -> UInt64 {
        return UInt64(Date().timeIntervalSince1970)
    }
    
    func getTimeshiftStartTime() -> UInt64 {
        return UInt64(TimeShiftRecorder.common().timestart!)
    }
    
    func getTimeshiftStopTime() -> UInt64 {
        return UInt64(Date().timeIntervalSince1970)
    }
    
    func shouldDisplayTimeshiftInfo() -> Bool {
        return true
    }
    func jumpTo(_ time:UInt64){
        
    }
    

}
