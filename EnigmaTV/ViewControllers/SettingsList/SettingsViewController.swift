//
//  SettingsViewController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 12.04.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import Reachability

class SettingsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tuners = [TunerInfo]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tuners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var x = tableView.dequeueReusableCell(withIdentifier: "tunercell")! as? TunerCell
        x?.configure(serv: tuners[indexPath.row])
        
        
        return x!
    }
    
    
    
    
    
    
    
    @IBOutlet weak var cbutton: UIButton!
    var f=false;
    @IBOutlet weak var info: UILabel!
    @IBAction func cbuttonCLicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var whe: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.whe.startAnimating()
        STBAPI.common()?.discoverNetwork(status: {p in
            print("Discovering: \(p)")
        }, success: { dat,address in
            print("Discovering successfull: \(address):")
            self.info.text = "Receiver found."
            /*self.f=true
            //self.cbutton.setTitle("OK", for: UIControlState.focused)
            self.cbutton.setTitle("OK", for: .focused)
            self.cbutton.setTitle("OK", for: .normal)
            //self.tapMenu(self)
            self.whe.alpha=0.0
            //self.perform(#selector(ViewController.tapMenu(_:)), with: self, afterDelay: 1.0)
            */
            dat.ip = address;
            self.tuners.append(dat)
            DispatchQueue.main.async {

                self.tableView.reloadData();
            }
            
        }, failure: { st in
            self.info.text = "Failed finding a device..."
             var reachability: Reachability?
            reachability = try! Reachability()
            reachability?.whenReachable = { reachability in
                DispatchQueue.main.async {
                    self.info.text = "No supported device in Your Network. Check  Your STB."
                }
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    self.info.text = "Network not found..."
                }
            }
            do
            {
                try reachability?.startNotifier()
            }catch{
                self.info.text = "General network error"
            }
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var manual: UIButton!
    @IBAction func mbuttonClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tuner.manualsetup"), object: nil)
        UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tc = tuners[indexPath.row]
        STBAPI.common()?.set(address:tc.ip!)
        if let apitype = tc.apitype{
            STBAPI.common()?.set(api:tc.apitype!)
        }else{
            STBAPI.common()?.set(api:"api")
        }
        STBAPI.common()?.saveSettings()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tuner.setupready"), object: nil)
    }

    
    
}
