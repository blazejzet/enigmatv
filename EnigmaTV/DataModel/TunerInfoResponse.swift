//
//  Service.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import SWXMLHash
class TunerInfoResponse:NSObject, Translateable{
    var info:TunerInfo?
    
    static var translation: [String : String] = [
        "info" :"/e2abouts"
    ]
    
    required override init(){
        
    }
    
    required init(xml:XMLIndexer){
        do{
        self.info = TunerInfo(xml:xml["e2abouts"])
        }catch{}
    }
}
