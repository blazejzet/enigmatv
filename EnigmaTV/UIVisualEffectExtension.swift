//
//  UIVisualEffectExtension.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 18/11/2019.
//  Copyright © 2019 Blazej Zyglarski. All rights reserved.
//

import UIKit

class UIVisualEffectExtension : UIVisualEffectView {

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 30.0
        self.clipsToBounds  = true
    }
    
    
}
