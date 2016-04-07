//
//  IntroViewController.swift
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/20/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

import UIKit

class BeginViewController: UIViewController, IntroViewDelegate {
    
    @IBOutlet var scroller: UIScrollView!
    
    var content: ISView!
    
    override func viewDidLoad() {
        content = ISView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 2048, height: 768)))
        content.intro.delegate = self
        content.picker.parentViewController = self
        scroller.addSubview(content)
        let rec = UITapGestureRecognizer(target: self, action: "onSTCTap")
        rec.numberOfTouchesRequired = 1
        rec.numberOfTapsRequired = 1
        rec.cancelsTouchesInView = false
        content.intro.stcPrompt.addGestureRecognizer(rec)
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        content.intro.startAnimation()
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        content.intro.stopAnimation()
        super.viewDidAppear(animated)
    }
    
    func onSTCTap() {
        scroller.setContentOffset(CGPoint(x: 1024, y: 0), animated: true)
    }
    
    func handleIntroViewTap(sender: IntroView) {
        scroller.setContentOffset(CGPoint(x: 1024, y: 0), animated: true)
    }
    
    func showAnswerForPiece(piece: TPieceView) {
        view.userInteractionEnabled = false
        performSegueWithIdentifier("showAnswer", sender: piece)
    }
    
    func showInfo() {
        performSegueWithIdentifier("showPickerInfo", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? AnswerViewController {
            dest.instigatingPiece = sender as! TPieceView
            dest.parent = self
        } else if let dest = segue.destinationViewController as? PickingInfoViewController {
            dest.parent = self
        }
        super.prepareForSegue(segue, sender: sender)
    }
}