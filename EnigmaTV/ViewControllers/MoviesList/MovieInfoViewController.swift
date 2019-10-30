//
//  MovieInfoViewController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 05.02.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

class MovieInfoViewController: UIViewController {

    @IBOutlet weak var posterSmall: UIImageView!
    
    //@IBOutlet weak var posterBig: UIImageView!
    
    @IBOutlet weak var ServiceNameLabel: UILabel!
    
    @IBOutlet weak var MovieTitleLabel: UILabel!
    
    @IBOutlet weak var movieDateLabel: UILabel!
    
    @IBOutlet weak var movieDurationLabel: UILabel!
    
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var DescLabel: UILabel!
    
    
    var movie:Movie?
    
    var delegate:MVCProt?
    
    @IBAction func deletePressed(_ sender: Any) {
        STBAPI.common()?.movieDelete(movie!)
        delegate?.reload()
        
        self.dismiss(animated: true, completion: nil);
        
    }
    
    @IBAction func PlayPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moviePlayed"), object: movie)
    }
    @IBAction func ContinuePressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "movieContinue"), object: movie)
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let movie = movie{
            MovieTitleLabel.text = movie.eventname
            DescLabel.text = movie.descriptionExtended
            //self.posterBig.alpha=0.0
            self.posterSmall.alpha=0.0
            ServiceNameLabel.text = movie.servicename
            self.sizeLabel.text = movie.filesize_readable
            self.movieDateLabel.text = movie.begintime
            print(movie.recordingtime!/60)
            print(movie.recordingtime!)
            let tins = UInt64(movie.recordingtime!)
            let tinm = tins/60
            self.movieDurationLabel.text = movie.length
            
            DescLabel.sizeToFit()
            STBAPI.common()?.searchInfoWeb(title: movie.eventname!, duration: Int(tinm), eid: 0, cb: {
                image, backdrop, eid, ok in
                DispatchQueue.main.sync {
                    
                    if (ok ){
                        
                        //self.posterBig.image = backdrop
                        self.posterSmall.image=image
                        UIView.animate(withDuration: 0.3, animations: {
                            self.posterSmall.alpha=1.0
                            //self.posterBig.alpha=1.0
                        })
                    
                        
                    }
                    
                }
            })
            
        }
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
