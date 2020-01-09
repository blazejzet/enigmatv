
//
//  STBAPI.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//lo

import UIKit


extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}




class STBAPI: NSObject {
    static var _stbapi:STBAPI?
    
    class func common()->STBAPI?{
        if (_stbapi==nil) {
            _stbapi = STBAPI();
        }
        return _stbapi;
    }
    class func restart(){
        _stbapi=nil
    }
    
    var stbAddress:String!
    var stbPort:String!
    var stbPort2:String!
    var stbProt:String!
    var tmdbApiKey:String!
    var timeshift:Bool!
    var zap:Bool!
    var useTranscoding:Bool!
    var username:String!
    var password:String!
    var apitype:String! = "api"
    
    var timers:TimerList?
    var stbStreamURLBase:String {
        return "\(stbProt!)://\(stbAddress!):\(stbPort!)/"
    }
    var stbURL:String {
        if let stbProt = stbProt{
            if let stbAddress = stbAddress{
                if let stbPort2 = stbPort2 {
                    return "\(stbProt)://\(stbAddress):\(stbPort2)"
                    
                }
                return "\(stbProt)://\(stbAddress)"
                
            }
        }
        return ""
    }
    
    func set(address:String){
        self.stbAddress = address
        
    }
    
    func getDelay() -> Double{
        
        if let s = UserDefaults.standard.string(forKey: "airplaydelay"){
            if let d  = Double(s){
                return d
                
            }
        }
        return 1.0
    }
    func set(api:String){
        print("Setting api as:\(api)")
        self.apitype = api
        
    }
    func ca(_ a:String)->URL{
        var ad = "\(stbURL)\(a)"
        
        return URL(string: ad)!
    }
    
    func discoverNetwork(status:((Int)->Void),success:@escaping ((TunerInfo,String)->Void),failure:((String)->Void)){
        //
        let adddresses = NetworkHelper.getNetworkIPAddresses()
        //let adddresses = NetworkHelper.getNetworkIPAddressesStupid2()
        
        if adddresses.count==0{
            failure("No network found. Please restart Your device.")
        }
        for address in adddresses {
            for apitype in ["api","web"]{
                //let helper = DispatchQueue(label: "\(apitype)\(address)")
                //DispatchQueue.main.async {
                
                DispatchQueue(label: "\(apitype)\(address)").async {
                    print("Checking \(address)")
                    do{
                        //Reachability();
                        let url = URL(string: "http://\(address)/\(apitype)/about")!
                        print("Checking url: \(apitype)::\(url)")
                        self.getContent(of:  url) { s in
                            if s.count > 0{
                                self.getTunerInfo(str: s,apitype:apitype, cb: {tinfo in
                                    DispatchQueue.main.async {
                                        success(tinfo,address)
                                    }
                                    print("       \(apitype)::\(address) is ok")
                                    print(tinfo)
                                })
                            }
                        }
                        
                    }catch{
                        
                    }
                }
            }
            
        }
        
        
    }
    
    func saveSettings(){
        let uds = UserDefaults.standard
        uds.set(self.stbPort, forKey: "stbPort")
        uds.set(self.stbPort2, forKey: "stbPort2")
        uds.set(self.stbProt, forKey: "stbProt")
        uds.set(self.tmdbApiKey, forKey: "tmdbApiKey")
        uds.set(self.timeshift, forKey: "timeshift")
        uds.set(self.zap, forKey: "zap")
        uds.set(self.apitype=="web",forKey: "oldapi")
        uds.set(self.stbAddress, forKey: "stbAddress")
        uds.set(self.username, forKey: "username")
        uds.set(self.password, forKey: "password")
        uds.synchronize()
    }
    func loadSettings(){
        let uds = UserDefaults.standard
        self.timeshift = uds.bool(forKey: "timeshift")
        self.zap = uds.bool(forKey: "zap")
        self.apitype = ((uds.bool(forKey: "oldapi")) ? "web" : "api")
        self.stbProt = uds.string(forKey: "stbProt")
        self.stbPort = uds.string(forKey: "stbPort")
        self.stbPort2 = uds.string(forKey: "stbPort2")
        self.username = uds.string(forKey: "username")
        self.password = uds.string(forKey: "password")
        
        
        //if uds.bool(forKey: "useTranscoding"){
        //    self.stbPort = uds.string(forKey: "stbTranscodingPort")
        ///    self.useTranscoding=true;
        //}else{
        self.useTranscoding=false;
        //}
        
        self.stbAddress = uds.string(forKey: "stbAddress")
        self.tmdbApiKey = "f40747d2a2888d38f5efff7d12f764b5";//uds.string(forKey: "tmdbApiKey")
    }
    
    func test(success:@escaping ((TunerInfo)->Void),failure:@escaping (()->Void)){
        let uds = UserDefaults.standard
        print("testing")
        let stbAddress = uds.string(forKey: "stbAddress")
        if(stbAddress==nil || stbAddress == "0.0.0.0"){
            //init def
            self.stbAddress = "0.0.0.0"
            self.zap = true
            self.stbPort = "8001"
            self.stbPort2 = "80"
            self.stbProt = "http"
            self.username = ""
            self.apitype = "api" // "web"
            self.password = ""
            self.tmdbApiKey = "f40747d2a2888d38f5efff7d12f764b5"
            self.timeshift = true
            self.useTranscoding=false;
            self.saveSettings()
        }
        self.loadSettings()
        print("self.stbAddress \(self.stbAddress)")
        if( self.stbAddress  == "0.0.0.0"){
            failure()
        }else{
            STBAPI.common()?.getInfo(success:{tinfo in
                success(tinfo)
            }, failure:{
                failure()
            })
        }
        
    }
    
    override init() {
        self.stbAddress = "10.0.0.38"
        self.stbPort = "8001"
        self.stbPort2 = "80"
        self.stbProt = "http"
        self.username = ""
        self.password = ""
        self.tmdbApiKey = "f40747d2a2888d38f5efff7d12f764b5"
        self.timeshift = true
        self.zap = false
        self.useTranscoding=false;
        super.init()
        self.loadSettings()
    }
    
    func getServices(cb:@escaping ((Servicelist)->Void), fail:@escaping (()->Void)){
        print("Getting ServiceList");
        //         EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        DispatchQueue(label: "preloading").sync {
            
            self.getContent(of: self.ca("/\(self.apitype!)/getservices")) { c in
                
                do{
                    let sl = try APIDecoder(self.apitype).decode(Servicelist.self, from: c.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                    //DispatchQueue.main.sync {
                    cb(sl)
                    //}
                    
                }catch{
                    fail()
                }
            }
        }
    }
    
    
    func getContent(of address: URL, cb: @escaping ((String)->Void)){
        
        print("getting content for \(address)")
        if let username = self.username, let password = self.password, self.username != "" {
            
            
            let loginString = "\(username):\(password)"
            
            guard let loginData = loginString.data(using: String.Encoding.utf8) else {
                return
            }
            let base64LoginString = loginData.base64EncodedString()
            var request = URLRequest(url: address)
            request.httpMethod = "GET"
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            
            
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            // make the request
            
            let task = session.dataTask(with: request) {
                (data, response, error)  in
                // check for any errors
                
                print(data)
                guard error == nil else {
                    
                    cb("");
                    return
                }
                // make sure we got data
                guard let responseData = data else {
                    
                    cb("");
                    return
                }
                
                if let s = String(data: responseData, encoding: .utf8){
                    //print("returned: \(s)")
                    cb(s);
                }else{
                    cb("");
                }
                
            }
            task.resume()
            
            
            
        }else{
            do {
                let c = try String(contentsOf:  address)
                cb(c);
            }
            catch{
                cb("")
            }
        }
        
    }
    
    
    func getInfo(success:@escaping ((TunerInfo)->Void),failure:@escaping (()->Void)){
        print("Getting Info");
        DispatchQueue.global().async {
            
            self.getContent(of: self.ca("/\(self.apitype!)/about"))  { c in
                self.getTunerInfo(str:c,apitype:self.apitype){tinfo in
                    success(tinfo)
                }
            }
        }
    }
    
    func getTunerInfo(str:String,apitype:String,cb:@escaping ((TunerInfo)->Void)){
        DispatchQueue.global(qos: .background).async {
            print("Getting MoviesList");
            do{
                
                let sl = try APIDecoder(apitype).decode(TunerInfoResponse.self, from: str.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                DispatchQueue.main.sync {
                    cb(sl.info!)
                    
                }
            }catch{
                print("Exception");
            }
        }
    }
    
    func getMovies(cb:@escaping ((MoviesList)->Void)){
        DispatchQueue.global(qos: .background).async {
            print("Getting MoviesList");
            self.getContent(of:  self.ca("/\(self.apitype!)/movielist")) { c in
                do{
                    print(c)
                    let sl = try APIDecoder(self.apitype).decode(MoviesList.self, from: c.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                    DispatchQueue.main.sync {
                        cb(sl)
                        
                        
                    }
                }catch{
                    print("Error");
                }
            }
        }
    }
    
    
    
    func getTimers(cb:@escaping ((TimerList)->Void)){
        DispatchQueue.global().async {
            
            
            print("Getting ServiceList");
            self.getContent(of:  self.ca("/\(self.apitype!)/timerlist")) { c in
                do{
                    
                    
                    let sl = try APIDecoder(self.apitype).decode(TimerList.self, from: c.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                    var newtimers = [RecordingTimer]()
                    if let timers = sl.timers{
                        for  t in timers{
                            if (t.state! < 3){
                                newtimers.append(t)
                            }
                        }
                    }
                    sl.timers = newtimers.reversed()
                    
                    
                    cb(sl)
                    
                }catch{
                    print("Error");
                }
            }
        }
    }
    
    func setTimer(sref:String, eid:Int, cb:@escaping ((Bool)->Void)){
        
        let ca = self.ca("/\(self.apitype!)/timeraddbyeventid?sRef=\(sref)&eventid=\(eid)")
        print(ca)
        self.getContent(of:  ca) {c in
            do{
                let sl = try APIDecoder(self.apitype).decode(Message.self, from: c.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                
                self.getTimers{ timers in
                    self.timers = timers
                }
                
                cb (sl.result!)
                
            }catch{
                print("Error");
                cb (false)
            }
        }
    }
    
    
    
    
    func getServices(for bouquet:Service, cb:@escaping ((Servicelist)->Void),fail:@escaping (()->Void)){
        print("Getting ServiceList for \(bouquet)");
        DispatchQueue(label: "preloading").sync {
            
            
            
            let d = (bouquet.servicereference?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
            self.getContent(of:  self.ca("/\(self.apitype!)/getservices?sRef=\(d)")) { c in
                print(c)
                do{
                    let sl = try APIDecoder(self.apitype).decode(Servicelist.self, from: c.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                    sl.bouquet=bouquet
                    var row = 0
                    if let services =  sl.services{
                        for s in services{
                            s.row=row
                            row += 1
                        }
                    }
                    //DispatchQueue.main.async {
                    cb(sl)
                    //}
                }catch{
                    print("Error");
                    fail()
                }
            }
            
            
            
            
            self.getTimers{ timers in
                self.timers = timers
            }
        }
    }
    
    func preloadEPG(serv:Service){
        var start  = UInt64(Date().timeIntervalSince1970)
        var end = start+60*60*24
        
        
        print("Preloading epg for serv: \(serv)")
        STBAPI.common()?.getServices(for:serv,cb:{ (sl:Servicelist) in
            var subservices = sl
            if let services = subservices.services{
                for service in services{
                    STBAPI.common()?.getEPG(for:service, from:start, to:end){ (events:[EpgEvent],service:Service) in
                        
                        
                        
                        
                        
                        for event in events{
                            print("e \(event) in \(service)")
                        }
                        
                    }
                }
            }
        },fail:{})
        
        
    }
    
    func nowPlaying(at sref:String, sname:String, cb:((EpgEventCacheProtocol?,EpgEventCacheProtocol?)->Void)?) {
        let time = Date().timeIntervalSince1970
        print("bbbbbbbbbbb func nowPlaying")
        DataProvider.def().getEpgForService(sref: sref, sname: sname, begin: Int64(time), end: Int64(time)+10000){
            events in
            if let nowPlaying = events.first {
//                print("bbbbbbbb nowPlaying.title \(nowPlaying.tilte)")
                for index in 0...events.count-1{
                    print("bbbbbbb events no \(index) = \(events[index].tilte)")
                    print("bbbbbbb events no \(index) = \(events[index].begin_timestamp)")
                }
                if events.count>1{
                    let nextPlaying = events[1]
//                     print("bbbbbbbb nextPlaying.title \(nextPlaying.tilte)")
                    if let  cb = cb{
                        cb(nowPlaying, nextPlaying)
                    }
                }else{
                    if let  cb = cb{
                        cb(nowPlaying,nil)
                    }
                }
            }
            
        }
        
        //TODO: FIX TIMING
        /*self.getEPG(for: service, from: UInt64(time), to: UInt64(time)+1){
         events, service in
         if let nowPlaying = events.first {
         if events.count>1{
         let nextPlaying = events[1]
         if let  cb = cb{
         cb(nowPlaying,nextPlaying)
         }
         }else{
         if let  cb = cb{
         cb(nowPlaying,nil)
         }
         }
         }
         
         }*/
        
    }
    
    func zap(for service:EpgService){
        let d = (service.sref?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        let n = (service.sname?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        
        let ad  = self.ca("/\(self.apitype!)/zap?sRef=\(d)&title=\(n)")
        do{
            print(ad)
            self.getContent(of:  ad) { c in
                print (c)
            }
        }catch{
            
        }
    }
    
    func movieDelete(_ m:Movie){
        let n = (m.serviceref?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))!
        let ad  = self.ca("/\(self.apitype!)/moviedelete?sRef=\(n)".replacingOccurrences(of: "+", with: "%2B"))
        do{
            self.getContent(of:  ad) {c in
                
            }
        }catch{
            
        }
    }
    func timerDelete(_ m:RecordingTimer){
        let n = (m.serviceref?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))!
        ///\(self.apitype!)/timerdelete?sRef=&begin=&end=
        let ad  = self.ca("/\(self.apitype!)/timerdelete?sRef=\(n)&begin=\(m.begin!)&end=\(m.end!)".replacingOccurrences(of: "+", with: "%2B"))
        do{
            self.getContent(of:  ad) { c in
                
            }
        }catch{
            
        }
    }
    func turnOff(){
        let ad  = self.ca("/\(self.apitype!)/powerstate?newstate=5")
        do{
            self.getContent(of:  ad) {c in
                
            }
        }catch{
            
        }
    }
    func reboot(){
        let ad  = self.ca("/\(self.apitype!)/powerstate?newstate=2")
        do{
            self.getContent(of:  ad) { c in
                
            }
        }catch{
            
        }
    }
    
    
    
    
    
    var cache = [String:[EpgEvent]?]();
    func getEPG(for service:Service, from start:UInt64, to end:UInt64, cb:@escaping (([EpgEvent],Service)->Void)){
        DispatchQueue(label: "preloading").sync  {
            print("This is run on the background queue")
            print("Getting Events for \(service)");
            do{
                let d = (service.servicereference?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                let ad  = self.ca("/\(self.apitype!)/epgservice?sRef=\(d)&time=\(start)&timeEnd=\(end)") //&time=\(start)&timeEnd=\(end)
                print(ad)
                if let key = service.servicereference{
                    if let list = self.cache[key]{
                        //DispatchQueue.main.sync {
                        if let list = list{
                            cb(self.filter(events: list, from: start, to: end),service)
                        }
                        //}
                    }else{
                        self.getContent(of:  ad) { c in
                            
                            do{
                                let sl = try APIDecoder(self.apitype).decode(Eventlist.self, from: c.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                                self.cache[key]=sl.events
                                //DispatchQueue.main.sync {
                                if let list = sl.events{
                                    cb(self.filter(events: list, from: start, to: end),service)
                                }
                                //}
                            }catch{
                                print("Error \(service)");
                            }
                        }
                    }
                }
            }catch{
                print("Error \(service)");
            }
            
        }
    }
    
    private func filter(events:[EpgEvent],from start:UInt64, to end:UInt64)->[EpgEvent]{
        
        let events:[EpgEvent] = events.filter({(e:EpgEvent)->Bool in
            var ok =  e.begin_timestamp!+e.duration_sec! >= start && e.begin_timestamp!<end
            if(ok){
                if let timers = timers?.timers{
                    for timer in timers{
                        if(e.id == timer.eit && e.sref == timer.serviceref){
                            e.timer = timer
                        }
                    }
                }
            }
            return ok
        })
        return events
    }
    
    func urlForRef(_ ref:String)->String{
        return "\(stbStreamURLBase)\(ref)"
    }
    
    
    
    
    func searchInfoWeb(title:String, duration:Int, eid:Int, cb:((UIImage?,UIImage?,Int,Bool)->Void)?){
        DispatchQueue.global(qos: .background).async {
            let b64 = title.toBase64()
            let fm = FileManager.default
            let furl = fm.temporaryDirectory.appendingPathComponent("\(b64)_fg")
            let fbgurl = fm.temporaryDirectory.appendingPathComponent("\(b64)_bg")
            print(furl.path)
            var askWeb=true
            if (fm.fileExists(atPath: furl.path)){
                do {
                    let d = try Data(contentsOf:furl)
                    let img = UIImage(data:d)
                    var img2: UIImage?
                    do{
                        let d2 = try Data(contentsOf:fbgurl)
                        img2 = UIImage(data:d2)
                    }catch{
                        
                    }
                    
                    print ("Z cache!")
                    askWeb = false
                    cb!(img,img2,eid,true)
                }catch{
                    
                }
            }
            
            
            if (askWeb){
                var t = title.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
                var query = "";
                if (duration > 80){
                    query = "https://api.themoviedb.org/3/search/movie?api_key=\(self.tmdbApiKey!)&query=\(t!)"
                }else{
                    query = "https://api.themoviedb.org/3/search/tv?api_key=\(self.tmdbApiKey!)&query=\(t!)"
                }
                
                self.getContent(of:  URL(string: query)!) { s in
                    do{
                        print(s);
                        print("TMDB>>>>");
                        var resp = try  JSONDecoder().decode(MovieInfoList.self, from: s.data(using: String.Encoding.utf8)!)
                        var img:UIImage?
                        var img2:UIImage?
                        var isdownloaded = false
                        if let  movies = resp.results{
                            if movies.count>0{
                                let m = movies[0]
                                //https://image.tmdb.org/t/p/original/4iJfYYoQzZcONB9hNzg0J0wWyPH.jpg
                                if let addr = m.poster_path {
                                    let faddr = "https://image.tmdb.org/t/p/w300\(addr)"
                                    if let addr = URL(string:faddr) {
                                        let x = try Data(contentsOf:addr)
                                        do{
                                            try  x.write(to: furl)
                                        }catch{
                                            
                                        }
                                        img = UIImage(data:x)
                                        isdownloaded=true
                                    }
                                }
                                if let addr = m.backdrop_path {
                                    let faddr = "https://image.tmdb.org/t/p/original\(addr)"
                                    if let addr = URL(string:faddr) {
                                        let x = try Data(contentsOf:addr)
                                        do{
                                            try  x.write(to: fbgurl)
                                        }catch{
                                            
                                        }
                                        img2 = UIImage(data:x)
                                        
                                    }
                                }
                            }
                        }
                        
                        cb!(img,img2,eid,isdownloaded)
                    }catch{
                        cb!(nil,nil,eid,false)
                    }
                }
            }
        }
    }
    
    
    ///\(self.apitype!)/getservices?sRef=
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    
    
    func getPicon(name:String)->UIImage?{
        var f = "\(name.lowercased().replacingOccurrences(of: " ", with: ""))"
        print(f);
        var p = Bundle.main.path(forResource: f, ofType: "png")
        if let p = p {
            return UIImage(contentsOfFile: p)
        }
        return nil
    }
    
}





/*//var r = Reachability(hostname: "\(address)");
 //r?.whenReachable = {r in
 do{
 let url = URL(string: "http://\(address)/\(apitype)/about")!
 print("Checking url: \(apitype)::\(url)")
 
 var conf = URLSessionConfiguration.default
 conf.timeoutIntervalForRequest=3
 conf.timeoutIntervalForResource=3
 
 let session = URLSession(configuration: conf)
 var dataTask = session.dataTask(with: url, completionHandler: {data, _, _ in
 if let data = data{
 if let s = String(data: data, encoding: .utf8){
 //let s = self.getContent(of:  url)
 if s.count > 0{
 self.getTunerInfo(str: s,apitype:apitype, cb: {tinfo in
 DispatchQueue.main.async {
 success(tinfo,address)
 }
 print("       \(apitype)::\(address) is ok")
 print(tinfo)
 })
 }
 }
 }
 })
 dataTask.resume()
 
 
 
 
 
 }catch let e as NSError{
 print(e)
 }
 //r.stopNotifier()
 // }
 
 //r?.whenUnreachable = {r in
 //    r.stopNotifier()
 // }
 //do{
 //    try r?.startNotifier()
 //}catch let e as NSError{
 //    print(e)
 //}
 //
 */
