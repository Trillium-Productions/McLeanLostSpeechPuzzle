//
//  AttractScreenViewController.swift
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/20/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AttractScreenViewController: AVPlayerViewController {
    
    let appdel = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {let url = NSBundle.mainBundle().URLForResource("starter", withExtension: "mp4")
        appdel.navigator = self.navigationController!
        player = AVPlayer(URL: url!)
        player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "restartVideo", name: AVPlayerItemDidPlayToEndTimeNotification, object: player!.currentItem)
        view.userInteractionEnabled = true
        let rec = UITapGestureRecognizer(target: self, action: "startInteractive")
        rec.numberOfTapsRequired = 1
        rec.numberOfTouchesRequired = 1
        let sub = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 768)))
        view.addSubview(sub)
        sub.addGestureRecognizer(rec)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        appdel.timer?.invalidate()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        restartVideo()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        player!.pause()
        super.viewWillDisappear(animated)
    }
    
    func restartVideo() {
        let secs: Int64 = 0
        let scale: Int32 = 1
        let time = CMTimeMake(secs, scale)
        player!.seekToTime(time)
        player!.play()
    }
    
    func startInteractive() {
        performSegueWithIdentifier("firstSegue", sender: self)
    }
    
}