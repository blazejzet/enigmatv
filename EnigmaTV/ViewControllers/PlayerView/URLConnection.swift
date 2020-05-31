//
//  URLConnection.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 23.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

class URLConnection: OperationQueue, URLSessionDataDelegate{

    var os:OutputStream?
    var dataTask:URLSessionDataTask?
    var receivedFirstData = false
    var delegate:TimeShiftRecorder?
    func connect(url:URL, to:URL){
        overallcount=0
        os = OutputStream(url: to, append: false)
        os?.open()
        
        var conf = URLSessionConfiguration.default
        
        
        
        
        
        
        let username = STBAPI.common()?.username
        let password = STBAPI.common()?.password
        if let username = username {
            if let password = password {
                if username.count>0{
                let loginString = String(format: "%@:%@", username, password)
                let loginData = loginString.data(using: String.Encoding.utf8)!
                let base64LoginString = loginData.base64EncodedString()
                let authString = "Basic \(base64LoginString)"
                conf.httpAdditionalHeaders = ["Authorization" : authString]
                    print("Authorization: connection: \(authString)")
                }
                
            }
        }
        
        let session = URLSession(configuration: conf, delegate: self, delegateQueue: OperationQueue.current)
        //var request = URLRequest(url: url)
        
        
        
        
        dataTask = session.dataTask(with: url)
        dataTask?.resume()
        
        //self.perform(#selector(startDelayed), with: nil, afterDelay: 0.5)
    }
    var isstarted = false;
    @objc func startDelayed(){
        if !isstarted {
            isstarted=true;
            delegate?.receivedFirstData()
        }
    }
    func stop(){
        if let dataTask = dataTask{
           
            self.dataTask?.cancel()
            self.dataTask = nil
            os?.close()
            os=nil
        }
    }
    var overallcount:Int=0
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        
        var count = os?.write(data: data)
        if let c  = count{
            overallcount += count!
           // print("[C] \(overallcount)");///
            if (overallcount)>17400{
                self.startDelayed()
            }
            
        }       
        
    }
    func getDataSize()->Int{
        return overallcount
    }
    
}
