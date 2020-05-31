//
//  ChannelSwipeViewController.swift
//  EnigmaTV
//
//  Created by Damian Skarżyński on 13/01/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import UIKit

class ChannelSwipeViewController: UIViewController{
    
    
    @IBOutlet weak var arrowLeft: UIButton!
    @IBOutlet weak var arrowRight: UIButton!
    
    @IBOutlet weak var piconRight: UIImageView!
    @IBOutlet weak var piconLeft: UIImageView!
    
    
    var initialDirection: Direction?
    var service: Service?
    var bouquet: Service?
    var services = [Service]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrowLeft.setTitleColor(.white, for: .disabled)
        arrowRight.setTitleColor(.white, for: .disabled)
        arrowRight.layer.cornerRadius = 50
        
        if let dir = initialDirection{
            print("csVC: \(dir)")
        }
        switch initialDirection{
        case .Left:
            arrowRight.isEnabled = false
            
        case .Right:
            arrowLeft.isEnabled = false
            
        default:
            break
            
        }
        
        if let name = bouquet?.servicereference, let service = service{
            DataProvider.def().getServices(bref: name){
                list in
                //                if let list = list{
                print("csVC list \(list)")
                self.services = list
                if self.services.count > 0{
                    self.setIcons(list: self.services, currentService: service)
                }
                
                
            }
        }
        
        
    }
    
    
    func setIcons(list: [Service]?, currentService service: Service?){
        if let list = list, let service = service{
            let row = Int(service.row!)
            let tmpLeftIndex = (row - 1) % list.count
            let rowLeftIndex = tmpLeftIndex >= 0 ? tmpLeftIndex : tmpLeftIndex + list.count
            let tmpRightIndex = (row + 1) % list.count
            let rowRightIndex = tmpRightIndex >= 0 ? tmpRightIndex : tmpRightIndex + list.count
            
            print("row= \(row) rowL= \(rowLeftIndex) rowR= \(rowRightIndex)")
            
            setLeftService(service: list[rowLeftIndex])
            setRightService(service: list[rowRightIndex])
        }
    }
    
    
    @IBAction func leftArrowClicked(_ sender: Any){
        if let row = service?.row{
            let tmpLeftIndex = (Int(row) - 1) % self.services.count
            let rowLeftIndex = tmpLeftIndex >= 0 ? tmpLeftIndex : tmpLeftIndex + self.services.count
            if self.services.count > 0{
                self.service = self.services[rowLeftIndex]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setMainPlayer"), object: nil, userInfo: ["service":self.service, "bouquet": self.bouquet, "direction": (-1)])
                setIcons(list: self.services, currentService: self.service)
            }
        }
    }
    
    @IBAction func rightArrowClicked(_ sender: Any){
        if let row = service?.row{
            let tmpRightIndex = (Int(row) + 1) % self.services.count
            let rowRightIndex = tmpRightIndex >= 0 ? tmpRightIndex : tmpRightIndex + self.services.count
            if self.services.count > 0{
                self.service = self.services[rowRightIndex]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setMainPlayer"), object: nil, userInfo: ["service":self.service, "bouquet": self.bouquet, "direction": (1)])
                setIcons(list: self.services, currentService: self.service)
            }
        }
    }
    
    func setLeftService(service: Service){
        
        if let name = service.servicename{
            if let p = STBAPI.common()?.getPicon(name: name){
                piconLeft.image = p
            }else{
                piconLeft.image = nil
            }
            
        }
        
    }
    
    func setRightService(service: Service){
        
        if let name = service.servicename{
            if let p = STBAPI.common()?.getPicon(name: name){
                piconRight.image = p
            }else{
                piconRight.image = nil
            }
        }
    }
    
    @IBAction func swipeRight(_ sender: Any){
        arrowRight.isEnabled = true
        arrowLeft.isEnabled = true
    }
    
    @IBAction func swipeLeft(_ sender: Any){
        arrowLeft.isEnabled = true
        arrowRight.isEnabled = true
    }
    
}
