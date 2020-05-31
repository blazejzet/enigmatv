//
//  Service.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import SWXMLHash

class Service:NSObject,  Translateable {
    var servicereference:String?
    var servicename:String?
    var program:Int?
    var pos:Int?
    
    //dodatkowe moje
    var row:Int?
    
    static var translation: [String : String] = [:]
    
    func getLogoURL()->URL{
        var name_ = "\(servicename!.lowercased().replacingOccurrences(of: " ", with: ""))"
        return URL(string: "https://asuri.pl/y/picons/\(name_).png")!
    }
    required override init(){
        
    }
    
    required init(xml:XMLIndexer){
        //print("\(xml["e2servicename"]) -- \(xml["e2servicereference"])")
        self.servicereference = xml["e2servicereference"].element?.text
        self.servicename = xml["e2servicename"].element?.text
    }
}
