
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
    
    
    
    
    func getEpgForService(sref:String,begin:Int64,end:Int64,cb:@escaping ([EpgEvent])->Void){
        
    }
    
    func getLastEpgForService(sref:String,cb:@escaping (Int64)->Void){
        
        
    }
    
    
    
    
    func getEpgForService(sref:String,begin:Int64,end:Int64){
        
    }
    
    
    func getBouquets( cb:@escaping ([Service])->Void){
        
    }
    
    
    
    func getBouquet(bref:String, cb:@escaping ((Service?)->Void)){
       
    }
    
    
    
    
    
    
    
    
    
    func getServices(bref:String,  cb:@escaping (([Service])->Void)){
        
        
    }
    func getService(bref:String,sref:String,  cb:@escaping ((Service?)->Void)){
        
    }
    
    
    
    
    
    
    
    


}

