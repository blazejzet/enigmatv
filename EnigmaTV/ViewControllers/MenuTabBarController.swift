//
//  MenuTabBarController.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 06/11/2019.
//  Copyright © 2019 Blazej Zyglarski. All rights reserved.
//

import UIKit

class MenuTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.items?[0].title="EPG"
        self.tabBar.items?[1].title="Recordings"
        self.tabBar.items?[2].title="Recordings #2"
        self.tabBar.items?[3].title="Settings"
        //self.tabBar.items?[3].title="Settings"

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
