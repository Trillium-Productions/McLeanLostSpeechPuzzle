//
//  IntroScrollView.swift
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/28/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

import UIKit

class ISView: UIView {
    
    @IBOutlet var intro: IntroView!
    @IBOutlet var picker: PickingView!
    
    func create() {
        let arr = NSBundle.mainBundle().loadNibNamed("IntroScrollView", owner: self, options: nil)
        for thing in arr {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        create()
    }
    
}
