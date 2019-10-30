//
//  Movie.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 17.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import SWXMLHash
class Movie:NSObject,  Translateable {
    var filename_stripped:String?
    var eventname:String?
    var recordingtime:Int64?
    var descriptionExtended:String?
    var servicename:String?
    var begintime:String?
    var filesize_readable:String?
    var serviceref:String?
    var length:String?
    
    
    static var translation: [String : String] = [:]
    
    required override init(){
        
    }
    
    required init(xml:XMLIndexer){
        do{
            var len = xml["e2length"].element!.text

            self.recordingtime = Int64(Int(len.split(separator: ":")[0])!*60+Int(len.split(separator: ":")[1])!)
        }catch{}
        do{
            self.filename_stripped = xml["e2filename"].element!.text
        }catch{}
        do{
            self.eventname = xml["e2title"].element!.text
        }catch{}
        do{
            self.descriptionExtended = xml["e2description"].element!.text
        }catch{}
        do{
            self.servicename = xml["e2servicename"].element!.text
        }catch{}
        do{
            let d = Date(timeIntervalSince1970: TimeInterval(Int(xml["e2time"].element!.text)!))
        self.begintime = "\(d)"
        }catch{}
        do{
            let size = Int(xml["e2filesize"].element!.text)!/1024/1024
        self.filesize_readable = "\(size) MB"
        }catch{}
        do{
            self.length = xml["e2length"].element!.text
        }catch{}
        do{
            self.serviceref = xml["e2servicereference"].element!.text
        }catch{}
        
    }
}


class MoviesList:NSObject, Translateable {
    var directory:String?
    var movies:[Movie?]?
    
    static var translation: [String : String] = [:]
    
    required override init(){
        
    }
    
    required init(xml:XMLIndexer){
        self.movies=[Movie?]()
        do{
        for xml in xml["e2movielist"].children{
            movies?.append(Movie(xml: xml))
        }
        }catch{}
        
    }
}
