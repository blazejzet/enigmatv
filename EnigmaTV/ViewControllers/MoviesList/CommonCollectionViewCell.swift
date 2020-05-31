//
//  CommonCollectionViewCell.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.05.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
class CommonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var shadYC: NSLayoutConstraint!
    @IBOutlet weak var topC: NSLayoutConstraint!
    @IBOutlet weak var hC: NSLayoutConstraint!
    @IBOutlet weak var wC: NSLayoutConstraint!
    @IBOutlet weak var midC: NSLayoutConstraint!
    
    @IBOutlet weak var recIcon: UILabel!
    
    
    @IBOutlet weak var bg: UIImageView!
   
    @IBOutlet weak var fg: UIImageView!
    
    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var del:Movies2ViewController?
    var backdrop:UIImage?
    var clv:UICollectionView?
    
    
    var topmargin:CGFloat = 40.0
    
    var sp: CGPoint?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        sp = touches.first?.location(in: self);
        print()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesMoved")
        if self.isFocused{
            let cp = touches.first?.location(in: self);
            var r = ((cp?.y)!-(sp?.y)!)/3
            
            var ry = ((cp?.y)!-(sp?.y)!)/16
            var rx = ((cp?.x)!-(sp?.x)!)/16
            if rx < 10 && rx > -10{
                self.midC.constant=rx
            }
            if ry < 10 && ry > -10{
                self.topC.constant=ry+self.topmargin
            }
            if deletingAvailable{
            if r>200{
                self.topC.constant=r-200+self.topmargin
            }
            print(r);
            if r>200{
                //deleting indicatori
                self.bg.tintColor = UIColor.red
            
                if r<350{
                    //do nothing
                    self.bg.alpha=1.0
                }
                if r>350{
                   self.bg.alpha=0.5
                }
            }
            }
        }else{
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
               self.topC.constant=self.topmargin
                self.layoutIfNeeded()
            })
        }
        print(touches.first?.location(in: self))
        
    }
    
    
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        let cp = touches.first?.location(in: self);
        var r = ((cp?.y)!-(sp?.y)!)/3
        
        
        if deletingAvailable{
        if r>350{
            print("deleting")
            UIView.animate(withDuration: 1.0, animations: {
                let ip = self.clv?.indexPath(for: self)
                self.deleteItem()
                if let ip = ip{
                    self.clv?.deleteItems(at: [ip])
                }
                
            }){ _ in
                DispatchQueue.main.async {

                    self.clv?.reloadData()
                
                }
            }
            
            
        }else{
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                self.topC.constant=self.topmargin
                self.midC.constant=0.0
                self.layoutIfNeeded()
            })
        }
        }else{
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                self.topC.constant=self.topmargin
                self.midC.constant=0.0
                self.layoutIfNeeded()
            })
        }
        print(touches.first?.location(in: self))
        
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled")
        print(touches.first?.location(in: self))
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
          self.topC.constant=self.topmargin
            self.midC.constant=0.0
            self.layoutIfNeeded()
        })
    }

    func configure(){
        self.topC.constant=self.topmargin
        self.bg.alpha=1.0
        self.backdrop = #imageLiteral(resourceName: "poster_placeholder2")
        self.bg.image = #imageLiteral(resourceName: "poster_placeholder2")
         self.fg.alpha = 0.0
        self.topmargin=40.0
        self.hC.constant=235
        self.wC.constant=166
        self.topC.constant = self.topmargin;
    }
    
    func piconSetup(name:String){
        var f = "\(name.lowercased().replacingOccurrences(of: " ", with: ""))"
        print(f);
        var p = Bundle.main.path(forResource: f, ofType: "png")
        print(p);
        if let p = p {
            self.bg.image = #imageLiteral(resourceName: "poster_placeholder2")
            self.fg.alpha = 1.0
            self.fg.image = UIImage(contentsOfFile: p)
            
        }else{
            self.fg.alpha = 0.0
        }
        
    }
    var f:(()->Void)?
    func backdropcb(f:@escaping (()->Void)){
    self.f=f
    }
    var deletingAvailable = true
    func requestImage(name:String,tinm:Int,servicename:String){
        if name == "NO DATA" {return;}
        print("Requesting \(name) \(tinm)")
        self.piconSetup(name: servicename)
        STBAPI.common()?.searchInfoWeb(title: name, duration: tinm, eid: 0) {
                image, backdrop, eid, ok in
                DispatchQueue.main.sync {
                    if (ok ){
                    
                        self.bg.image = image
                        self.backdrop = backdrop
                        if self.isSelected{
                            self.f?()
                        }
                        //self.posterSmall.image=image
                    UIView.animate(withDuration: 0.3){
                        
                        }
                    }
                
            }
        }
    }
    func deleteItem(){
        
    }
    
    func getTitle()->String?{return ""};
     func getService()->String?{return ""};
     func getLength()->String?{return ""};
    func getSize()->String?{return ""};
    func getDate()->String?{return ""};
    
    func select(){
        self.layoutIfNeeded()
         UIView.animate(withDuration: 0.2) {
            self.hC.constant =  295
            self.wC.constant = 194
            self.topmargin = 10.0
            self.shadYC.constant=40.0
            self.topC.constant = self.topmargin;
            self.f?()
            self.layoutIfNeeded()
        }
    }
    
    func deselect(){
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.hC.constant=255
            self.wC.constant=166
            self.shadYC.constant=0.0
            self.topmargin = 40.0
            self.f=nil
            self.topC.constant = self.topmargin;
            self.layoutIfNeeded()
        }
    }
}
