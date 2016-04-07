//
//  IntroView.swift
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/20/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

import UIKit

protocol IntroViewDelegate {
    func handleIntroViewTap(sender: IntroView)
}

@IBDesignable class IntroView: UIView {
    
    @IBOutlet weak var stcPrompt: UIImageView!
    
    var delegate: IntroViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let arr = NSBundle.mainBundle().loadNibNamed("introview", owner: self, options: nil)
        for thing in arr {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let arr = NSBundle.mainBundle().loadNibNamed("introview", owner: self, options: nil)
        for thing in arr {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
    }
    
    func startAnimation() {
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: stcPrompt.frame.width * 8 / 3, height: stcPrompt.frame.height)
        maskLayer.backgroundColor = UIColor.clearColor().CGColor
        maskLayer.contents = UIImage(named: "maskstcprompt")!.CGImage
        let tAnimation = CABasicAnimation(keyPath: "position.x")
        tAnimation.fromValue = stcPrompt.frame.width * 4 / 3
        tAnimation.toValue = -stcPrompt.frame.width / 3
        tAnimation.repeatCount = FLT_MAX
        tAnimation.duration = 2.5
        tAnimation.removedOnCompletion = false
        stcPrompt.layer.mask = maskLayer
        maskLayer.addAnimation(tAnimation, forKey: "mysecretkey")
    }
    
    func stopAnimation() {
        stcPrompt.layer.mask?.removeAllAnimations()
    }
    
    @IBAction func onTapNext(sender: UITapGestureRecognizer) {
        delegate?.handleIntroViewTap(self)
    }
    
}