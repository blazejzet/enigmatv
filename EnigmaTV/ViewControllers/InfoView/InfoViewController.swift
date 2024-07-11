//
//  InfoViewController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 18.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import SDWebImage

class InfoViewController: UIViewController {

    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var hour: UILabel!
    
    
    
    @IBOutlet weak var top: NSLayoutConstraint!
    
    @IBOutlet weak var bottom: UIView!
    
    
    @IBOutlet weak var picon: UIImageView!
    
    @IBOutlet weak var pvrInfo: UILabel!
    
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var current_time: UILabel!
    @IBOutlet weak var nowHourLabel: UILabel!
    @IBOutlet weak var nowNameLabel: UILabel!
    @IBOutlet weak var nextHourLabel: UILabel!
    @IBOutlet weak var nextNameLabel: UILabel!
    
    @IBOutlet weak var recordingTimeBar: UIImageView!
    @IBOutlet weak var currentBar: UIImageView!
    @IBOutlet weak var currenttimeIndicator: UIImageView!
    @IBOutlet weak var nextBar: UIImageView!
    
    
    var delegate:ViewController?
    var edp:InfoViewDataProviderDelegate?{
        didSet{
            self.configure()
        }
    }
    
    var movie:Movie?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.top.constant = 733
        self.view.layoutSubviews()
        bottom.alpha=0.0
        let date = Date()
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("HH:mm")
        hour.text  =  df.string(from: date)
        
        df.setLocalizedDateFormatFromTemplate("dd")
        day.text  =  df.string(from: date)
        df.setLocalizedDateFormatFromTemplate("MMMM")
        month.text = df.string(from: date)
        df.setLocalizedDateFormatFromTemplate("yyyy")
        year.text = df.string(from: date)
        
    }
    override func viewDidAppear(_ animated: Bool) {
       
        self.view.layoutSubviews()
        UIView.animate(withDuration: 0.3, animations: {
            self.top.constant = 633
            self.view.layoutSubviews()
            self.bottom.alpha=1.0
            
        })
       
        
        self.configure()
        
        self.perform(#selector(InfoViewController.hide), with: nil, afterDelay: 5.0)
        if let labels = textslabels{
            for label in labels{
                label.textColor = .white
                label.tintColor = .white
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        let ds = Date()
        let dsh =  dateFormatter.string(from:ds)
        
        dateLabel.text = dsh
    }
    
    
    @objc func hide(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func timeToPoint(time:UInt64)->CGFloat{
        let event = edp?.getCurrentEvent()
        let cb = self.currentBar
        let cbf = cb?.frame
        if let event_wholetime =  event?.duration_sec {
            let jedn = (cbf?.size.width)!/CGFloat(event_wholetime)
            let ts = Int32(time) - Int32((event?.begin_timestamp)!)
            return (cbf?.origin.x)! + CGFloat(ts)*jedn
        }
        return 0.0
    }
    
    func pointToTime(point:CGFloat)->UInt64{
        let event = edp?.getCurrentEvent()
        let cb = self.currentBar
        let cbf = cb?.frame
        let event_wholetime =  (event?.duration_sec)!
        let jedn = (cbf?.size.width)!/CGFloat(event_wholetime)
        //let ts =
        return UInt64((point + (CGFloat((event?.begin_timestamp)!))*jedn - (cbf?.origin.x)!)/jedn)
    }
    
    
    func posistionBar(){
        let event = edp?.getCurrentEvent()
        let ci = self.currenttimeIndicator
        let cb = self.currentBar
        let cbf = cb?.frame
        
        let now_timestamp = edp?.getCurrentTime()
        var left = self.timeToPoint(time: now_timestamp!)
        
            ci?.frame = CGRect(origin: CGPoint(x:left,y:(cbf?.origin.y)!), size: (ci?.frame.size)!)
        
        
        setPos(i: now_timestamp!)
        
        if (edp?.shouldDisplayTimeshiftInfo())!{
        let ti = self.recordingTimeBar
        let right = self.timeToPoint(time: (edp?.getTimeshiftStopTime())!)
             left = self.timeToPoint(time: (edp?.getTimeshiftStartTime())!)
        
        let width =   right - left
        
        var height = ci?.frame.size.height
        
            UIView.animate(withDuration: 0.1){
            ti?.frame = CGRect(origin:  CGPoint(x:left,y:(cbf?.origin.y)!), size: CGSize(width: width, height: height!))
        }
    
        }
        
    }
    
    
    @IBAction func tapPLay(_ sender: Any) {
        delegate?.playPausePressed(sender)
    }
    @IBAction func tapLeft(_ sender: Any) {
    delegate?.tapLeft(sender)
    }
    
    @IBAction func tapRight(_ sender: Any) {
        delegate?.tapRight(sender)
    }
    
    
    func piconSetup(name:String){
        var name_ = "\(name.lowercased().replacingOccurrences(of: " ", with: ""))"
        picon.sd_setImage(with: URL(string: "https://asuri.pl/y/picons/\(name_).png"), completed: nil)
        
        
    }
    func configure(){
        
        DispatchQueue.main.async {
            
            if let pi = self.pvrInfo{
                var ds = TimeShiftRecorder.common().conn2?.getDataSize()
                if let ds = ds{
                    
                    //self.pvrInfo.text = "\(ds)"
                    
                }else{
                    //self.pvrInfo.text = "x"
                    
                }
                if let _ = self.dateLabel{
                    
                    if let event = self.edp?.getCurrentEvent(){
                        print("rrrrrrrrrrrr")
                        
                        self.pvrInfo.text = "\(Int(event.duration_sec!/60)) min."
                        self.nowHourLabel.text = event.getBeginTimeString()
                        //nowHourLabel.setTex
                        
                        
                        print("nowNameLabel: \(event.title)")
                        self.nowNameLabel.text = event.title
                        self.serviceName.text = event.sname
                        self.piconSetup(name: event.sname!)
                        
                        
                        self.posistionBar()
                    }
                }
                
                if let event = self.edp?.getNextEvent(){
                    let ds = Date(timeIntervalSince1970: TimeInterval(event.begin_timestamp!))
                    let dateFormatter = DateFormatter()
                    dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
                    self.nextHourLabel.text = dateFormatter.string(from: ds)
                    self.nextNameLabel.text = event.title
                }else{
                    
                    self.nextHourLabel.alpha = 0.0
                    self.nextNameLabel.alpha = 0.0
                }
                self.serviceName.text = self.edp?.getServiceName()
                if let edp = self.edp{
                    self.min = self.timeToPoint(time: edp.getTimeshiftStartTime())
                    self.max = self.timeToPoint(time:  edp.getTimeshiftStopTime())
                    
                    print("min:\(Date(timeIntervalSince1970: TimeInterval(self.min!))) max: \(Date(timeIntervalSince1970: TimeInterval(self.max!)))")
                }
            }
            
        }
    }
    
    var min:CGFloat?
    var max:CGFloat?
    var start:CGFloat?
    var touch_start:CGFloat?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let edp = edp {
            if edp.shouldDisplayTimeshiftInfo() {
        
            start = self.currenttimeIndicator.frame.origin.x
            
            var ctt = self.pointToTime(point: start!)
            print("    > current:\(Date(timeIntervalSince1970: TimeInterval(ctt)))")
            if let t = touches.first{
                touch_start = t.location(in: self.view).x
            }
        
            }
        }
    }
    
    func setPos(i now_timestamp:UInt64){
        let ci = self.currenttimeIndicator
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        let ds = Date(timeIntervalSince1970: Double(now_timestamp))
        let dsh =  dateFormatter.string(from:ds)
        self.current_time.text = dsh
        self.current_time.center =
            CGPoint(x: ci!.center.x, y: self.current_time.center.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let x = edp?.shouldDisplayTimeshiftInfo() {
            if let t = touches.first{
                let touch_move = t.location(in: self.view).x
                let change = (touch_move - touch_start!)/10
             //   print("     touch with change \(change)")
                let np = start! + change
                if np>min! && np<max! {
                self.currenttimeIndicator.frame = CGRect(origin: CGPoint(x:np,y:self.currenttimeIndicator.frame.origin.y), size: self.currenttimeIndicator.frame.size)
                    var new_time = self.pointToTime(point: np)
                    setPos(i: new_time)
                }
            }
        }
    }
    
    @IBOutlet var textslabels: [UILabel]!
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let edp = edp{
        if (edp.shouldDisplayTimeshiftInfo()){
            
            if let t = touches.first{
                let touch_move = t.location(in: self.view).x
                let change = (touch_move - touch_start!)/10
              //  print("ended touch with change \(change)")
                var np = start! + change
               // print("    np \(np)")
                if np > max! {
                    np = max!
                }
                if np < min!{
                    np = min!
                }
                if np>=min! && np<=max! {
                    self.currenttimeIndicator.frame = CGRect(origin: CGPoint(x:np,y:self.currenttimeIndicator.frame.origin.y), size: self.currenttimeIndicator.frame.size)
                    var new_time = self.pointToTime(point: np)
                    print("    > new_time:\(Date(timeIntervalSince1970: TimeInterval(new_time)))")
                    edp.jumpTo(new_time)
                }
            }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
