//
//  BouquetsGalleryViewController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 26/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import UIKit

class BouquetsGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    static let sectionHeaderElementKind = "section-header-element-kind"
    var servicelist:Servicelist?
    var servicechannels = [String:Servicelist]()
    var events = [String:[EpgEvent]]()
    
    @IBOutlet weak var bg: UIImageView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let s = servicelist?.services?[section] {
            if let cha = servicechannels[s.servicereference!]{
                return cha.services?.count ?? 0
            }
        }
        return 0
    }
    
    
     var svtmp: StreamView?
    @IBOutlet weak var cv: UICollectionView!
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       var c =  collectionView.cellForItem(at: indexPath) as? NowCollectionViewCell
        //print(c?.sref)
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setMainPlayer2"), object: nil, userInfo: ["ref":c!.sref])
//        if let s = c?.service, let b = c?.bouquet{
//         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPlayed"), object: ["service":s, "bouquet": b], userInfo: ["direction":0])
//        }
       // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPlayed"), object: ["service":c!.service!, "bouquet": c!.bouquet!], userInfo: ["direction":0])
        //setIcons(list: self.services, currentService: self.service)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let indexPath = context.nextFocusedIndexPath{
            var c = collectionView.cellForItem(at: indexPath) as? NowCollectionViewCell
            if let s = c?.service, let b = c?.bouquet{
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPrepared"), object: ["service":s, "bouquet": b], userInfo: ["direction":0])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = cv.indexPathsForSelectedItems?.first{
        var c =  cv.cellForItem(at: indexPath) as? NowCollectionViewCell
        
        if let ds = segue.destination as? TVEventViewController{
            if let s = c?.service, let b = c?.bouquet, let e = c?.event{
             //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPlayed"), object: ["service":s, "bouquet": b], userInfo: ["direction":0])
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPrepared"), object: ["service":s, "bouquet": b], userInfo: ["direction":0])
                ds.configure(s: s, b: b,e: e)
            }
        }
        }
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//
//         var c =  collectionView.cellForItem(at: indexPath) as? NowCollectionViewCell
//         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPrepared"), object: ["service":c!.service!, "bouquet": c!.bouquet!], userInfo: ["direction":0])
//       // svtmp?.play(c!.service!, inBouquet:  c!.bouquet!)
//    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var x = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! NowCollectionViewCell
        if let s = servicelist?.services?[indexPath.section] {
            if let cha = servicechannels[s.servicereference!]{
                if let chan = cha.services?[indexPath.row]{
                    x.label.text = chan.servicename
                    
                    STBAPI.common()?.getEPG(for: chan, from: 0, to: 0){
                        events, service in
                        if let f = events.first{
                            DispatchQueue.main.async {
                                x.setup(e: f,service: service,bouquet: s)
                            }
                        }
                    }
                    
                }
                
            }
        }
        
        return x;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return servicelist?.services?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var x = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! HeaderView
        x.label.text = "Bukiet"
        if let s = servicelist?.services?[indexPath.section] {
            x.label.text = s.servicename
        }
        return x
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //svtmp = StreamView()
        //self.bg.addSubview(svtmp!)
        cv.register(
        HeaderView.self,
        forSupplementaryViewOfKind: BouquetsGalleryViewController.sectionHeaderElementKind,
        withReuseIdentifier: HeaderView.reuseIdentifier)
        
        cv.collectionViewLayout = ScrollableSectionCollectionViewLayout.create()
        STBAPI.common()?.getServices(cb: {slist in
            print(slist.services?.count)
            
                
            
            self.servicelist = slist
                
                for s in slist.services! {
                    
                    STBAPI.common()?.getServices(for: s, cb: {channelslist in
                        self.servicechannels[s.servicereference!]=channelslist
                        //for ch in channelslist.services!{
                            
                        //}
                        
                        DispatchQueue.main.async {
                            self.cv.reloadData()
                        }
                    }, fail: {
                        
                    })
                }
            DispatchQueue.main.async {
                self.cv.reloadData()
            }
        }, fail: {})

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
