//
//  EPGHelper.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 09/05/2019.
//  Copyright © 2019 Blazej Zyglarski. All rights reserved.
//

import UIKit

class EPGHelper {
    static var epgHelperInstance: EPGHelper?
    var isFetching = false
    var serialPrefetchQueue:DispatchQueue?
    //var asyncDataQueue:DispatchQueue?
    
    class func getInstance() -> EPGHelper?{
        if EPGHelper.epgHelperInstance == nil {
            EPGHelper.epgHelperInstance = EPGHelper()
            
        }
        return EPGHelper.epgHelperInstance
    }
    
    init() {
        self.serialPrefetchQueue = DispatchQueue(label: "pl.asuri.enigma.prefetch")
        //self.asyncDataQueue = DispatchQueue(label: "pl.asuri.enigma.data", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    }
    
    class func getBouquets(cb:@escaping (([EpgBouquet])->Void)){
//        EPGHelper.getInstance()?.asyncDataQueue?.async {
        
            DataProvider.def().getBouquetsSerial { bouquets in
                DispatchQueue.main.async {
                    cb(bouquets)
                }
            }
        
    }
    
    
    
    class func showAll(text:String?){
        print("[SHOWALL]  Show ALL in \(text)\n")
            EPGHelper.getInstance()?.displayall(text: text)
        
    }
    
    
    func testClear(){
        DataProvider.def().clearSavedBouquets()
    }
    
    class func preloadingEPG() {
        print("[EPGHELPER]: Preparing  prefetching")
        
        EPGHelper.getInstance()?.preload()
        
        
    }
    
    func displayall(text: String?)  {
       
            
        
        print("[SHOWALL]  DisplayAll \(text!) [QUEUE: \(OperationQueue.current?.underlyingQueue?.description)]")
        DataProvider.def().getBouquetsSerial{
            list in
            for l in list {
                print("[SHOWALL]         - N: \(l.sname!) R: \(l.sref!) (\(l.objectID)) [\(text)]")
            }
        }
            
    }
    
    func preload()
    {
        
        if(!self.isFetching ){
            self.serialPrefetchQueue?.async {

                DataProvider.def().removeOldEPG(olderThan: Int64(Date().timeIntervalSince1970 - 60*60*24))
                
                print("[EPGHELPER] starting new prefetch")

                var start  = UInt64(Date().timeIntervalSince1970)
                var end = start+60*60*72 // NA 3 DNI.

                STBAPI.common()?.getServices(cb: {(sl:Servicelist) in
                    if let services = sl.services {
                        self.serialPrefetchQueue?.async {
                            for bouquet in services{
                                print("[EPGHELPER]    prefetching 'st bouquet \(bouquet.servicename)")

                                DataProvider.def().getBouquetSerial(bref: bouquet.servicereference!){ b in
                                    print("[EPGHELPER]    processing     bouquets serial\(b?.sname)")
                                    if let b  = b{
                                        print("[EPGHELPER]    bouquet \(b.sname) already exists in database")
                                    }else{
                                        DispatchQueue.main.async{
                                        var x = EpgBouquet(context: DataProvider.def().context)
                                        x.sname = bouquet.servicename
                                        x.sref = bouquet.servicereference
                                        print("[EPGHELPER]    adding bouquet \(bouquet.servicename) to database")
                                            
                                         DataProvider.def().saveContext()
                                        }
                                    }
                                    //TODO: deleting bouquets that dont exist in database
                                }
                                self.serialPrefetchQueue?.async {
                                    STBAPI.common()?.getServices(for: bouquet, cb: {list in
                                        if let services = list.services{
                                            print("[EPGHELPER]    prefetching \(services.count) in bouquet \(bouquet)")
//                                            print("-----------------------------C-----------------------------")

                                            for service in services {
                                                print("[EPGHELPER]    prefetching \(service.servicename) in bouquet \(bouquet)")
//                                                print("-----------------------------CC--------------0---------------")

                                                DataProvider.def().getServiceSerial(bref: bouquet.servicereference!, sref: service.servicereference!){ b in
                                                    
                                                    if let b = b{
                                                        print("[EPGHELPER]    service \(bouquet.servicename)/\(service.servicename) already exists in database")
//                                                        print("-----------------------------CC1-----------------------------")
                                                    }else{
                                                        DispatchQueue.main.async{
                                                        var x = EpgService(context: DataProvider.def().context)
                                                        x.sname = service.servicename
                                                        x.sref = service.servicereference
                                                        x.bref = bouquet.servicereference
                                                        print("[EPGHELPER]    adding service \(bouquet.servicename)/\(service.servicename) to database")
//                                                        print("-----------------------------CC2-----------------------------")
//                                                        DataProvider.def().saveContextSerial()
                                                        DataProvider.def().saveContext()
                                                        }
                                                    }
                                                }


                                                print("[EPGHELPER]    prefetching \(service.servicename) bouquet")
                                                //todo: compute dates.

                                                //---------------------------------------------------------------------------
                                                
                                                DataProvider.def().getLastEpgForServiceSerial(sref: service.servicereference!){ start in
                                                    var end = start+60*60*72
                                                    print("[EPGHELPER - programs x1]    prefetching \(service.servicename) bouquet [\(start) -- \(end)]")
                                                    //                                                    print("-----------------------------D-----------------------------")
                                                    
                                                    
                                                    ///Get program list
                                                    STBAPI.common()?.getEPG(for:service, from:UInt64(start), to:UInt64(end)){ (events:[EpgEvent],service:Service) in
                                                        
                                                        //                                                                                                        self.serialPrefetchQueue?.async{
                                                        self.serialPrefetchQueue?.async {
                                                            //todo: check if EPGDataFetchInfo exists in database
                                                            DispatchQueue.main.async{
                                                                var x = EPGDataFetchInfo(context: DataProvider.def().context)
                                                                x.lasttimestamp =  Int64(end)
                                                                x.serviceid = service.servicereference
                                                                //                                                            DataProvider.def().saveContextSerial()
                                                                DataProvider.def().saveContext()
                                                            }
                                                            print("[EPGHELPER - programs x2]    \(events.count) in \(service)")
                                                            //                                                            print("-----------------------------DD-----------------------------")
                                                            for event in events{
                                                                print("[EPGHELPER - programs for1]    EVENT \(event) in \(service)")
                                                                //                                                                print("-----------------------------DDD-----------------------------")
                                                                
                                                                DispatchQueue.main.async{
                                                                    var e = EpgEventCache(context: DataProvider.def().context)
                                                                    if let t = event.begin_timestamp{
                                                                        e.begin_timestamp = Int64(event.begin_timestamp!)
                                                                        e.end_timestamp = Int64(event.begin_timestamp!+event.duration_sec!)
                                                                        e.dudation_sec = Int64(event.duration_sec!)
                                                                        
                                                                    }
                                                                    e.tilte = event.title
                                                                    e.longdesc = event.longdesc
                                                                    if let id = event.id{
                                                                        e.id = Int64(id)
                                                                    }
                                                                    e.sname = event.sname
                                                                    e.sref = event.sref
                                                                    e.shortdesc = event.shortdesc
                                                                    if let t = event.now_timestamp{
                                                                        e.now_timestamp =  Int64(t)
                                                                    }
                                                                    print("[EPGHELPER - programs for2]   \"e\" before saveContext \(e)" )
                                                                    //                                                                DataProvider.def().saveContextSerial()
                                                                    DataProvider.def().saveContext()
                                                                }
                                                            }
                                                        }
                                                        print("[EPGHELPER - programs end]    left \(self.isFetching) bouquets for prefetching")
                                                    }
                                                }
                                                
                                                //---------------------------------------------------------------------------
                                            }
                                            //Deleting missing services
                                            DataProvider.def().getServices(bref: bouquet.servicereference!){ list in
                                                for item in list {
                                                    if services.contains(where: {$0.servicename == item.sname}){
                                                        print("Test Delete: - service exists \(item.sname)")
                                                    }else{
                                                        print("Test Delete: - service doesn't exist")
                                                        DataProvider.def().removeService(bref: bouquet.servicereference!, sref: item.sref!)
                                                        DataProvider.def().saveContext()
                                                    }
                                                }
                                            }
                                        }
                                        
                                        
                                        
                                        
                                        
                                        
                                    }, fail: {
                                        print("[EPGHELPER]    Failed to preload data")
                                        self.isFetching = false
                                    })
                                }
                            }
                            
                            //Deleting missing bouquets
                            DataProvider.def().getBouquetsSerial() { list in
                                for item in list {
                                    if services.contains(where: {$0.servicename == item.sname}){
                                        print("Test Delete: - bouquet exists \(item.sref)")
                                    }else{
                                        print("Test Delete: - bouquet doesn't exist \(item.sref)")
                                        DataProvider.def().removeBouquet(bref: item.sref!)
                                        DataProvider.def().saveContext()
                                    }
                                }
                                
                            }
                            
                            
                            
                            
                            
                        }
                        self.serialPrefetchQueue?.async {
                            //                                                    self.isFetching = false;
                            print("[EPGHELPER]    END OF STORY")
                        }

                    }
                }, fail: {
                    print("[EPGHELPER]    Failed to preload data")
                    self.isFetching = false
                })
            }
        }
    }
}
