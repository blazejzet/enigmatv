//
//  Movies2ViewController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.05.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

import CloudKit


class Movies2ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,MVCProt {
var delegate:EPGViewController?
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropView: UIView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lenLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var moviesCountLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    override func viewDidLoad() {
        //super.view = self.collectionView
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
       

        // Do any additional setup after loading the view.
        
        reload()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        var all = 0
        if let movies =  mlist?.movies{
            all += movies.count
        }
        if let timers = tlist?.timers{
            all += timers.count
        }
        return all
        
    }
    
    func findCK(movie:Movie)->CKRecord?{
        
        var ref = CKRecordID(recordName: movie.serviceref!)
        if let list = self.rlist{
            for  ckr in list{
                if (ckr.recordID.isEqual(ref)){
                    
                    return ckr
                }
            }
        }
        return nil;
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var lim = 0
        if let timers = tlist?.timers{
            lim =  timers.count
        }
        
        if indexPath.row >= lim{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "xx", for: indexPath)
            if let cell = cell as? MovieCollectionViewCell{ //MovieCell
                cell.clv = collectionView
                //cell.bg.adjustsImageWhenAncestorFocused=true
                if let movies =  mlist?.movies{
                    let movie = movies[indexPath.row-lim]
                    cell.configure(serv: movie!,ck:self.findCK(movie:movie!))
                    cell.del = self
                }
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "yy", for: indexPath)
            if let cell = cell as? TimerCollectionViewCell{ //TimerCell
                cell.clv = collectionView
                //cell.bg.adjustsImageWhenAncestorFocused=true
                if let timers =  tlist?.timers{
                    let timer = timers[indexPath.row]
                    cell.configure(serv: timer)
                    cell.del = self
                }
            }
            
            return cell
        }
        
        
    }
    
    
    func delete(movie:Movie){
       mlist?.movies?.removeFirst()
        //STUB
    }
    
    func delete(timer:RecordingTimer){
        tlist?.timers?.removeFirst()
        //STUB
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    
    var mlist :MoviesList?
    var tlist :TimerList?
    
    var rlist :[CKRecord]?
    
    
     func showcount(){
        var c = 0
        if let cc = self.tlist?.timers {
            c+=cc.count
        }
        if let cc = self.mlist?.movies {
            c+=cc.count
        }
        self.moviesCountLabel.text = "\(c) RECORDINGS"
    }
    
      func reload(){
        print("Reloading info from iCloud and db.")
        STBAPI.common()?.getMovies(){
            moviesList in
            self.mlist = moviesList
            DispatchQueue.main.async {

                self.collectionView.reloadData()
            }
            self.showcount()
        }
        
        STBAPI.common()?.getTimers(){
            tList in
            self.tlist = tList
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.showcount()
                
            }
            
        }
        let myContainer = CKContainer.default()
        let privateCloudDatabase = myContainer.privateCloudDatabase
        //let id = CKRecordID(recordName: serv.serviceref!)
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "MovieInfo", predicate: predicate)
        
        privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records else {
                print("Error querying records: ", error)
                return
            }
            print("Found \(records.count) records matching query")
            self.rlist=records
            DispatchQueue.main.async{
                self.collectionView.reloadData()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let pp = context.previouslyFocusedIndexPath{
        if let cm:CommonCollectionViewCell =  collectionView.cellForItem(at: pp) as? CommonCollectionViewCell {
            cm.deselect()
        }
        }
        if let pp = context.nextFocusedIndexPath{
        if let cm:CommonCollectionViewCell =  collectionView.cellForItem(at: pp) as? CommonCollectionViewCell {
            
            cm.backdropcb{
            UIView.transition(with: self.backdropImageView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.backdropImageView?.image = cm.backdrop },
                              completion: nil)
            self.titleLabel?.text = cm.getTitle();
            self.serviceLabel?.text = cm.getService();
            self.lenLabel?.text = cm.getLength();
            self.sizeLabel?.text = cm.getSize();
                self.dateLabel?.text = cm.getDate();
            }
            cm.select()
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var lim = 0
        if let timers = tlist?.timers{
            lim =  timers.count
        }
        if let s = segue.destination as? MovieInfoViewController{
            if let movies =  mlist?.movies{
                if let indexPath = collectionView.indexPathsForSelectedItems?.first{
                    if let movie = movies[indexPath.row-lim]{
                        s.movie = movie
                        s.delegate=self
                    }
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}
