//
//  TVEventViewController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 30/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import UIKit

class TVEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            var d = tableView.dequeueReusableCell(withIdentifier: "nowcell") as! NowTableViewCell
            d.setup(e: self.event!)
            return d;
        }
        
        if indexPath.row == 1{
        var d = tableView.dequeueReusableCell(withIdentifier: "nextlabel")
            return d!;
        }
        
        
        var d = tableView.dequeueReusableCell(withIdentifier: "nextcell")
        return d!;

        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            
            return 300
        }
        return 66
    }
    
    var bouquet:Service?
    var service:Service?
     var event:EpgEvent?
 
    
    @IBOutlet weak var tv: UITableView!
    
    
    @IBAction func watchnow(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bouquetPlayed"), object: ["service":service!, "bouquet":bouquet!], userInfo: ["direction":0])
    }
    
    @IBAction func record(_ sender: Any) {
        
    }
    @IBAction func watchpip(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pipPlayed"), object: ["service":service!, "bouquet":bouquet!], userInfo: ["direction":0])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
            
        
        // Do any additional setup after loading the view.
    }
    
    func setup(){
        
    }
    func configure(s:Service,b:Service,e:EpgEvent){
        self.bouquet = b
        self.service = s
        self.event = e
        setup()
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
