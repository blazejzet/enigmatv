//
//  XMLDecoder.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 18.06.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

class APIDecoder: NSObject {
    var type:String
    init(_ type:String){
        self.type = type
    }
    
    open func decode<T>(_ type: T.Type, from data: Data) throws -> T where T :Translateable,T:NSObject{
        if self.type == "api" {
            return try JSONDecoder().decode(type, from: data)
        }else{
            return try XMLDecoder().decodeData(type, fromData: data)
        }
    }
    
}
