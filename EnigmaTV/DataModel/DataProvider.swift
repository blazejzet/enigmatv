
//  DataProvider.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 09/05/2019.
//  Copyright © 2019 Blazej Zyglarski. All rights reserved.
//

import UIKit
import CoreData

class DataProvider: NSObject {
    static var instance: DataProvider?
    
    
    class func def() -> DataProvider{
        if DataProvider.instance == nil {
            //{
            DataProvider.instance = DataProvider()
            //}
        }
        return DataProvider.instance!
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EPGData")
        //        DispatchQueue.main.sync {
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        //        }
        
        return container
    }()
    
    
    lazy var context: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    
    
    func clearSavedBouquets(){
        //  EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        self.context.perform {
            do{
                let frc = self.getFetchedResultsControllerEPG()
                frc.fetchRequest.predicate = NSPredicate(format: "end_timestamp > %d ", 1)
                try frc.performFetch()
                if let obj = frc.fetchedObjects{
                    for epgec in obj{
                        epgec.delete()
                    }
                }
                
            }catch{
                
            }
            
        }
        
    }
    
    func saveContext () {
        //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        
        //        EPGHelper.getInstance()?.asyncDataQueue?.async {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            //                            EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            self.context.perform {
                do {
                    try context.save()
                    print("DataProvider: Context saved")
                    
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
            //                }
        }
        //  }
    }
    
    //    func saveContextSerial () {
    //
    //        EPGHelper.getInstance()?.serialPrefetchQueue?.async?.async {
    //            let context = self.persistentContainer.viewContext
    //            if context.hasChanges {
    //                EPGHelper.getInstance()?.serialPrefetchQueue?.async {
    //
    //                    do {
    //                        try context.save()
    //                        print("DataProvider: Context saved")
    //
    //                    } catch {
    //                        let nserror = error as NSError
    //                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func getEpgForService(sref:String,begin:Int64,end:Int64,cb:@escaping ([EpgEventCache])->Void){
        //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        self.context.perform {
            
            let frc = self.getFetchedResultsControllerEPG()
            frc.fetchRequest.predicate = NSPredicate(format: "sref = %@ && begin_timestamp > %d && end_timestamp < %d", sref,begin,end)
            self.context.perform {
                do{
                    try frc.performFetch()
                    if let obj = frc.fetchedObjects{
                                    print("fetched \(frc.fetchedObjects?.count) objects")
                                   cb(obj)
                                   
                               }
                }catch{
                    
                }
                
            }
            
            
           
        }
        //}
    }
    
    func getLastEpgForService(sref:String,cb:@escaping (Int64)->Void){
        self.context.perform {
            // EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            
            let frc = self.getFetchedResultsControllerEPG()
            frc.fetchRequest.predicate = NSPredicate(format: "sref = %@ ", sref)
            frc.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "end_timestamp", ascending: false)]
            self.context.perform {
                do{
                    try frc.performFetch()
                }catch{
                    
                }
            }
            if let e = frc.fetchedObjects {
                //  EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                if let f = e.first{
                    cb(f.begin_timestamp+f.dudation_sec)
                }else{
                    cb(Int64(Date().timeIntervalSince1970))
                }
                
                //  }
            }
            
        }
        
    }
    
    func getLastEpgForServiceSerial(sref:String,cb:@escaping (Int64)->Void){
        self.context.perform {
            // EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            
            //        EPGHelper.getInstance()?.serialPrefetchQueue?.async?.async {
            
            let frc = self.getFetchedResultsControllerEPG()
            frc.fetchRequest.predicate = NSPredicate(format: "sref = %@ ", sref)
            frc.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "end_timestamp", ascending: false)]
            self.context.perform {
                do{
                    try frc.performFetch()
                }catch{
                    
                }
            }
            if let e = frc.fetchedObjects {
                //                     self.context.perform {
                if let f = e.first{
                    cb(f.begin_timestamp+f.dudation_sec)
                }else{
                    cb(Int64(Date().timeIntervalSince1970))
                }
            }
            //                    }
            
            
            // }
        }
    }
    
    
    
    func getEpgForService(sref:String,begin:Int64,end:Int64){
        //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        self.context.perform {
            
            let frc = self.getFetchedResultsControllerEPG()
            frc.fetchRequest.predicate = NSPredicate(format: "sref = %@ && begin_timestamp > %@ && end_timestamp < %@", sref,begin,end)
            self.context.perform {
                do{
                    try frc.performFetch()
                }catch{
                    
                }
                print("fetched \(frc.fetchedObjects?.count) objects")
                if let obj = frc.fetchedObjects{
                    for o in obj {
                        print(o.tilte)
                    }
                }

            }
            //  }
        }
    }
    
    
    func getBouquets( cb:@escaping ([EpgBouquet])->Void){
        // EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        self.context.perform {
            
            let frc = self.getFetchedResultsControllerBouquets()
            self.context.perform {
                do{
                     try frc.performFetch()
                    self.fetchedResultsControllerBouquetsDelegate.cb={
                                           if let obj = frc.fetchedObjects{
                                               //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                                               cb(obj)
                                               //}
                                           }
                                       }
                   
                }catch{
                    
                }
            }
            
            
        }
    }
    
    func getBouquetsSerial( cb:@escaping ([EpgBouquet])->Void){
       
        self.context.perform{
            let frc = self.getFetchedResultsControllerBouquets()
                do{
                    try frc.performFetch()
                    self.fetchedResultsControllerBouquetsDelegate.cb={
                                           if let obj = frc.fetchedObjects{
                                               //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                                               cb(obj)
                                               //}
                                           }
                                       }
                    
                }catch{
                    print ("Context error")
                }
    }
    }
    
    
    
    func getBouquet(bref:String, cb:@escaping ((EpgBouquet?)->Void)){
        self.context.perform {
            
            let frc = self.getFetchedResultsControllerBouquets()
            
            frc.fetchRequest.predicate = NSPredicate(format: "sref = %@", bref)
            self.context.perform {
                do{
                    
                    try frc.performFetch()
                    self.fetchedResultsControllerBouquetsDelegate.cb={
                        if let obj = frc.fetchedObjects{
                            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                            cb(obj.first)
                            //}
                        }
                    }
                    
                }catch{
                    
                }
            }
            
            
        }
    }
    
    
    func getBouquetSerial(bref:String, cb:@escaping ((EpgBouquet?)->Void)){
        self.context.perform {
            
            let frc = self.getFetchedResultsControllerBouquets()
            frc.fetchRequest.predicate = NSPredicate(format: "sref = %@", bref)
            self.context.perform {
                do{
                    try frc.performFetch()
                    self.fetchedResultsControllerBouquetsDelegate.cb={
                        if let obj = frc.fetchedObjects{
                            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                            cb(obj.first)
                            //}
                        }
                    }
                    
                }catch{
                    
                }
            }
        }
    }
    
    
    
    func getServices(bref:String,  cb:@escaping (([EpgService])->Void)){
        self.context.perform {
            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            //        EPGHelper.getInstance()?.asyncDataQueue?.async {
            
            let frc = self.getFetchedResultsControllerServices()
            frc.fetchRequest.predicate = NSPredicate(format: "bref = %@", bref)
            self.context.perform {
                do{
                    try frc.performFetch()
                    self.fetchedResultsControllerServicesDelegate.cb = {
                        if let obj = frc.fetchedObjects{
                            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                            cb(obj)
                            //}
                        }
                    }
                }catch{
                    
                }
            }
        }
    }
    
    func getService(bref:String,sref:String,  cb:@escaping ((EpgService?)->Void)){
        self.context.perform {
            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            
            let frc = self.getFetchedResultsControllerServices()
            frc.fetchRequest.predicate = NSPredicate(format: "bref = %@ && sref = %@", bref,sref)
            self.context.perform{
                do{
                    try frc.performFetch()
                    self.fetchedResultsControllerServicesDelegate.cb = {
                        if let obj = frc.fetchedObjects{
                            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                            cb(obj.first)
                            //}
                        }
                    }
                }catch{
                    
                }
            }
        }
    }
    
    func getServiceSerial(bref:String,sref:String,  cb:@escaping ((EpgService?)->Void)){
        
        self.context.perform {
            let frc = self.getFetchedResultsControllerServices()
            frc.fetchRequest.predicate = NSPredicate(format: "bref = %@ && sref = %@", bref,sref)
            
            self.context.perform {
                do{
                    try frc.performFetch()
                    self.fetchedResultsControllerServicesDelegate.cb = {
                        if let obj = frc.fetchedObjects{
                            
                            cb(obj.first)
                        }
                    }
                }catch{
                    
                }
                
            }
            
        }
        
    }
    
   
    
    /*
 */
    /*
    func getServices(bref:String,  cb:@escaping (([EpgService])->Void)){
        self.context.perform {
            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            //        EPGHelper.getInstance()?.asyncDataQueue?.async {
            
            let frc = self.fetchedResultsControllerServices
            frc.fetchRequest.predicate = NSPredicate(format: "bref = %@", bref)
            self.context.perform {
                do{
                    try frc.performFetch()
                }catch{
                    
                }
            }
            if let obj = frc.fetchedObjects{
                //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                cb(obj)
                //}
            }
            
        }
        
    }
    
     func getService(bref:String,sref:String,  cb:@escaping ((EpgService?)->Void)){
         self.context.perform {
             //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
             
             let frc = self.fetchedResultsControllerServices
             frc.fetchRequest.predicate = NSPredicate(format: "bref = %@ && sref = %@", bref,sref)
             
                 do{
                     try frc.performFetch()
                 }catch{
                     
                 }
             
             if let obj = frc.fetchedObjects{
                 //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                 cb(obj.first)
                 
                 
             }
             
             
         }
     }
     
    func getServiceSerial(bref:String,sref:String,  cb:@escaping ((EpgService?)->Void)){
                   
            let frc = self.fetchedResultsControllerServices
            frc.fetchRequest.predicate = NSPredicate(format: "bref = %@ && sref = %@", bref,sref)
        
                do{
                    try frc.performFetch()
                }catch{
                    
                }
            if let obj = frc.fetchedObjects{
        
                cb(obj.first)
        }
    }
    
  */
    
    
    
    
    
    
    
    
    
    func  getFetchedResultsControllerEPG() -> NSFetchedResultsController<EpgEventCache> {
        let pc = self.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<EpgEventCache> = EpgEventCache.fetchRequest()
        
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "begin_timestamp", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: pc, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
        
    }
    
    
    
    
    fileprivate var fetchedResultsControllerBouquetsDelegate = EpgBouquetDelegate()
    private var _fetchedResultsControllerBouquets:NSFetchedResultsController<EpgBouquet>!
    public func getFetchedResultsControllerBouquets() -> NSFetchedResultsController<EpgBouquet>  {
        print("[DATA PROVIDER] New NSFetchedResultsController<EpgBouquet>")
            let pc = self.persistentContainer.viewContext
        
            let fetchRequest: NSFetchRequest<EpgBouquet> = EpgBouquet.fetchRequest()
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sname", ascending: true)]
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: pc, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self.fetchedResultsControllerBouquetsDelegate
            _fetchedResultsControllerBouquets = fetchedResultsController
            return _fetchedResultsControllerBouquets
    }
    
    
    fileprivate var fetchedResultsControllerServicesDelegate = EpgServiceDelegate()
    private var _fetchedResultsControllerServices: NSFetchedResultsController<EpgService>!
    public func getFetchedResultsControllerServices() -> NSFetchedResultsController<EpgService> {
        print("[DATA PROVIDER] New NSFetchedResultsController<EpgService>")
        let pc = self.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<EpgService> = EpgService.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sname", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: pc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self.fetchedResultsControllerServicesDelegate
        _fetchedResultsControllerServices = fetchedResultsController
        
        return _fetchedResultsControllerServices
    }
    
    
    
    /*
    */
    fileprivate lazy var fetchedResultsControllerServices: NSFetchedResultsController<EpgService> = {
        let pc = self.persistentContainer.viewContext
        do {
            let fetchRequest: NSFetchRequest<EpgService> = EpgService.fetchRequest()
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sname", ascending: true)]
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: pc, sectionNameKeyPath: nil, cacheName: nil)
            return fetchedResultsController
        }catch{
            
        }
        
    }()
    /*
    */
    
    
    
    
}




class EpgBouquetDelegate : NSObject, NSFetchedResultsControllerDelegate {
    var cb : (()->Void)? {
        didSet{
            cb?()
        }
    }
    //func controller
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("[DELEG] Will change EpgBouquetDelegate NSFetchedResultsController Query")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("[DELEG] Changed EpgBouquetDelegate NSFetchedResultsController Query")
        
    //cb?()
    }
    
    
}

class EpgServiceDelegate : NSObject, NSFetchedResultsControllerDelegate {
    var cb : (()->Void)? {
        didSet{
            cb?()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("[DELEG - s] Will change EpgServiceDelegate NSFetchedResultsController Query")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("[DELEG - s] Changed EpgServiceDelegate NSFetchedResultsController Query")
        
   // cb?()
    }
}

