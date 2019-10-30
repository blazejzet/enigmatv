
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
        context.performAndWait {
            do{
                let frc = self.fetchedResultsControllerEPG
                frc.fetchRequest.predicate = NSPredicate(format: "end_timestamp > %d", 1)
                try frc.performFetch()
            }catch{
                
            }
            if let obj = self.fetchedResultsControllerEPG.fetchedObjects{
                for epgec in obj{
                    epgec.delete()
                }
            }
        }
        
    }
    
    func saveContext () {
        //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        
        //        EPGHelper.getInstance()?.asyncDataQueue?.async {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            //                            EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            context.performAndWait {
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
        context.performAndWait {
            do{
                let frc = self.fetchedResultsControllerEPG
                frc.fetchRequest.predicate = NSPredicate(format: "sref = %@ && begin_timestamp > %d && end_timestamp < %d", sref,begin,end)
                try frc.performFetch()
            }catch{
                
            }
            print("fetched \(self.fetchedResultsControllerEPG.fetchedObjects?.count) objects")
            if let obj = self.fetchedResultsControllerEPG.fetchedObjects{
                //    EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                cb(obj)
                //}
            }
        }
        //}
    }
    
    func getLastEpgForService(sref:String,cb:@escaping (Int64)->Void){
        context.performAndWait {
            // EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            do{
                let frc = self.fetchedResultsControllerEPG
                frc.fetchRequest.predicate = NSPredicate(format: "sref = %@ ", sref)
                frc.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "end_timestamp", ascending: false)]
                try frc.performFetch()
                if let e = frc.fetchedObjects {
                    //  EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                    if let f = e.first{
                        cb(f.begin_timestamp+f.dudation_sec)
                    }else{
                        cb(Int64(Date().timeIntervalSince1970))
                    }
                    
                    //  }
                }
            }catch{
                
            }
        }
        
    }
    
    func getLastEpgForServiceSerial(sref:String,cb:@escaping (Int64)->Void){
        context.performAndWait {
            // EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            
            //        EPGHelper.getInstance()?.serialPrefetchQueue?.async?.async {
            do{
                let frc = self.fetchedResultsControllerEPG
                frc.fetchRequest.predicate = NSPredicate(format: "sref = %@ ", sref)
                frc.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "end_timestamp", ascending: false)]
                try frc.performFetch()
                if let e = frc.fetchedObjects {
                    //                     context.performAndWait {
                    if let f = e.first{
                        cb(f.begin_timestamp+f.dudation_sec)
                    }else{
                        cb(Int64(Date().timeIntervalSince1970))
                    }
                }
                //                    }
                
            }catch{
                
            }
            // }
        }
    }
    
    
    
    func getEpgForService(sref:String,begin:Int64,end:Int64){
        //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        context.performAndWait {
            do{
                let frc = self.fetchedResultsControllerEPG
                frc.fetchRequest.predicate = NSPredicate(format: "sref = %@ && begin_timestamp > %@ && end_timestamp < %@", sref,begin,end)
                try frc.performFetch()
            }catch{
                
            }
            print("fetched \(self.fetchedResultsControllerEPG.fetchedObjects?.count) objects")
            if let obj = self.fetchedResultsControllerEPG.fetchedObjects{
                for o in obj {
                    print(o.tilte)
                }
            }
            //  }
        }
    }
    
    
    func getBouquets( cb:@escaping ([EpgBouquet])->Void){
        // EPGHelper.getInstance()?.serialPrefetchQueue?.async {
        context.performAndWait {
            do{
                let frc = self.fetchedResultsControllerBouquets
                try frc.performFetch()
                if let obj = frc.fetchedObjects {
                    //   EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                    cb(obj)
                    // }
                }
            }catch{
                //  }
            }
        }
    }
    
    func getBouquetsSerial( cb:@escaping ([EpgBouquet])->Void){
        context.performAndWait {
            
            
            // EPGHelper.getInstance()?.serialPrefetchQueue?.async{
            //            EPGHelper.getInstance()?.serialPrefetchQueue?.async?.async {
            do{
                let frc = self.fetchedResultsControllerBouquets
                
                try frc.performFetch()
                if let obj = frc.fetchedObjects {
                    print("-----------dataprovider/getbouquets-----------\(obj.count)")
                    //   EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                    cb(obj)
                    //  }
                }
            }catch{
                //  }
            }
        }
    }
    
    
    
    func getBouquet(bref:String, cb:@escaping ((EpgBouquet?)->Void)){
        context.performAndWait {
            do{
                let frc = self.fetchedResultsControllerBouquets
                frc.fetchRequest.predicate = NSPredicate(format: "sref = %@", bref)
                try frc.performFetch()
                if let obj = frc.fetchedObjects{
                    //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                    cb(obj.first)
                    //}
                }
            }catch{
                //  }
            }
        }
    }
    
    
    func getBouquetSerial(bref:String, cb:@escaping ((EpgBouquet?)->Void)){
        context.performAndWait {
            //EPGHelper.getInstance()?.serialPrefetchQueue?.async{
            //        EPGHelper.getInstance()?.serialPrefetchQueue?.async?.async {
            do{
                let frc = self.fetchedResultsControllerBouquets
                frc.fetchRequest.predicate = NSPredicate(format: "sref = %@", bref)
                try frc.performFetch()
                if let obj = frc.fetchedObjects{
                    //  EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                    cb(obj.first)
                    //}
                }
            }catch{
            }
        }
        //}
    }
    
    
    
    
    
    
    
    
    
    func getServices(bref:String,  cb:@escaping (([EpgService])->Void)){
        context.performAndWait {
            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            //        EPGHelper.getInstance()?.asyncDataQueue?.async {
            do{
                let frc = self.fetchedResultsControllerServices
                frc.fetchRequest.predicate = NSPredicate(format: "bref = %@", bref)
                try frc.performFetch()
                if let obj = frc.fetchedObjects{
                    //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                    cb(obj)
                    //}
                }
            }catch{
            }
        }
        
    }
    func getService(bref:String,sref:String,  cb:@escaping ((EpgService?)->Void)){
        context.performAndWait {
            //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
            do{
                let frc = self.fetchedResultsControllerServices
                frc.fetchRequest.predicate = NSPredicate(format: "bref = %@ && sref = %@", bref,sref)
                try frc.performFetch()
                if let obj = frc.fetchedObjects{
                    //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                    cb(obj.first)
                    
                    
                }
            }catch{
                
            }
            
        }
    }
    
    
    func getServiceSerial(bref:String,sref:String,  cb:@escaping ((EpgService?)->Void)){
        context.performAndWait {
            //        EPGHelper.getInstance()?.serialPrefetchQueue?.async?.async {
            do{
                let frc = self.fetchedResultsControllerServices
                frc.fetchRequest.predicate = NSPredicate(format: "bref = %@ && sref = %@", bref,sref)
                try frc.performFetch()
                if let obj = frc.fetchedObjects{
                    //EPGHelper.getInstance()?.serialPrefetchQueue?.async {
                    cb(obj.first)
                    
                    //obj.first?.refresh(mergeChanges: <#T##Bool#>, in: <#T##NSManagedObjectContext#>)
                }
            }catch{
            }
        }
    }
    
    
    
    
    
    
    
    
    fileprivate lazy var fetchedResultsControllerEPG: NSFetchedResultsController<EpgEventCache> = {
        let pc = self.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<EpgEventCache> = EpgEventCache.fetchRequest()
        
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "begin_timestamp", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: pc, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
        
    }()
    
    
    
    
    
    fileprivate lazy var fetchedResultsControllerBouquets: NSFetchedResultsController<EpgBouquet> = {
        let pc = self.persistentContainer.viewContext
        do {
            let fetchRequest: NSFetchRequest<EpgBouquet> = EpgBouquet.fetchRequest()
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sname", ascending: true)]
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: pc, sectionNameKeyPath: nil, cacheName: nil)
            return fetchedResultsController
        }catch{
            
        }
        
    }()
    
    
    
    
    
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
    


}

