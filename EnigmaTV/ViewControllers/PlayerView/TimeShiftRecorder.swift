//
//  TimeShiftRecorder.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 22.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import AVFoundation
import CoreFoundation
import AVKit

class TimeShiftRecorder: NSObject {
    static var _tsr:TimeShiftRecorder?
    var delegate:StreamView?
    
    class func common() -> TimeShiftRecorder{
        if let tsr = TimeShiftRecorder._tsr{
            return tsr
        }else{
            TimeShiftRecorder._tsr = TimeShiftRecorder()
            return TimeShiftRecorder._tsr!
        }
    }
    
    
    override init(){
        
    }
    
    
    
    
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var conn2:URLConnection?
    var timestart:TimeInterval?
    
    public func stop(){
        print("stopping recording")
        if let urlc = conn2{
            //urlc exists.
            urlc.stop();
        }
    }
    
    private func record (from:URL, to:URL){
        self.stop()
        print("recording from: \(from) to: \(to)")
        conn2 = URLConnection()
        conn2?.delegate=self
        conn2?.connect(url: from, to:to)
        timestart = Date().timeIntervalSince1970
    }
    public func getIntervalsinceBeginning()->TimeInterval{
        return Date().timeIntervalSince1970-timestart!
    }
    
    public func receivedFirstData(){
        delegate?.receivedFirstData()
    }
    
    var fileurl:URL?
    var service:EpgService?
    var bouquet:EpgBouquet?
    var events:[EpgEventCacheProtocol]?
    public func startTimeShift(for url:URL,service:EpgService, inBouquet bouquet:EpgBouquet)-> URL{
        self.service = service;
        self.bouquet = bouquet;
        STBAPI.common()?.zap(for: service);
        /*STBAPI.common()?.getEPG(for: service, from: UInt64(Date().timeIntervalSince1970), to: UInt64(Date().timeIntervalSince1970+60.0*60.0*5.0), cb: {events, _ in
            self.events = events
        })*/
        
        DataProvider.def().getEpgForService(sref: service.sref!, sname: service.sname!, begin: Int64(UInt64(Date().timeIntervalSince1970)), end: Int64(UInt64(Date().timeIntervalSince1970+60.0*60.0*5.0))){
            events in
            self.events = events as! [EpgEventCacheProtocol]
        }
        
        
        
        fileurl = FileManager.default.temporaryDirectory.appendingPathComponent("timeshift.ts")
        
        try! FileManager.default.createFile(atPath: (fileurl!.path), contents: nil, attributes: nil)
        self.record(from: url, to: fileurl!)
        return fileurl!
    }
    
    
    
}
