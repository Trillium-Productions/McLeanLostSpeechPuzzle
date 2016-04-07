//
//  puzzleclasses.swift
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/29/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

import UIKit

class PoppingCheck: UIImageView {
    let centerPoint: CGPoint
    
    init(atCenterPoint point: CGPoint) {
        centerPoint = point
        super.init(frame: CGRect(origin: centerPoint, size: CGSizeZero))
        image = UIImage(named: "greencheck")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func popApprovinglyToSize(size: CGSize, duration: NSTimeInterval, delay: NSTimeInterval, completion: (() -> Void)?) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: { () -> Void in
            self.frame = PoppingCheck.getFrameWithCenter(self.centerPoint, withSize: size)
            }, completion: { (finsihed: Bool) -> Void in
                UIView.animateWithDuration(0.5, animations:
                    { () -> Void in
                        self.alpha = 0
                    }, completion: { (finsihed2: Bool) -> Void in
                        completion?()
                    }
                )
            }
        )
    }
    
    static func getFrameWithCenter(center: CGPoint, withSize size: CGSize) -> CGRect {
        let origin = CGPoint(x: center.x - (0.5 * size.width), y: center.y - (0.5 * size.height))
        return CGRect(origin: origin, size: size)
    }
}

protocol PuzzleInfoButtonDelegate {
    func puzzleInfoButtonClicked()
}

@IBDesignable class PuzzleContainerView: UIView {
    
    let ACCEPTABLE_ROTATION_RANGE = CGFloat(M_PI / 6)
    let ACCEPTABLE_DISTANCE: CGFloat = 30
    
    @IBOutlet var overlay: UIImageView!
    let dprov = (UIApplication.sharedApplication().delegate as! AppDelegate).DATA_PROVIDER
    
    func create() {
        let arr = NSBundle.mainBundle().loadNibNamed("PuzzleContainer", owner: self, options: nil)
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
    
    func originForType(type: FilledPiece) -> CGPoint {
        return dprov.frameForPiece(type, withPuzzleSize: bounds.size).origin
    }
    
    func originForType(type: FilledPiece, inView view: UIView) -> CGPoint {
        return convertRect(dprov.frameForPiece(type, withPuzzleSize: bounds.size), toView: view).origin
    }
    
    func validateDraggablePosition(piece: DraggablePieceView) -> Bool {
        if piece.angleIsInRangeOfZero(ACCEPTABLE_ROTATION_RANGE) {
            let correct = originForType(piece.type)
            return piece.positionInView(self, isWithinDistance: ACCEPTABLE_DISTANCE, ofPoint: correct)
        }
        return false
    }
    
}

enum CongratViewColor {
    case Yellow
    case Blue
    case Purple
    
    func getImage() -> UIImage {
        switch self {
        case .Yellow:
            return UIImage(named: "yellow-congratulations")!
        case .Blue:
            return UIImage(named: "blue-congratulations")!
        case .Purple:
            return UIImage(named: "purple-congratulations")!
        }
    }
}

func middleOfRect(frame: CGRect, withSize size: CGSize) -> CGRect {
    let left = frame.origin.x + 0.5 * (frame.width - size.width)
    let top = frame.origin.y + 0.5 * (frame.height - size.height)
    return CGRect(origin: CGPoint(x: left, y: top), size: size)
}

class CongratView: PassthroughView {
    let yellow: UIImageView
    let yframe: CGRect
    let blue: UIImageView
    let bframe: CGRect
    let purple: UIImageView
    let pframe: CGRect
    let parent: UIView
    
    init(withParent: UIView) {
        parent = withParent
        var image = CongratViewColor.Yellow.getImage()
        let _height = parent.frame.height
        var width = image.size.width * _height / image.size.height
        yframe = middleOfRect(parent.bounds, withSize: CGSize(width: width, height: _height))
        yellow = UIImageView(frame: middleOfRect(parent.bounds, withSize: CGSizeZero))
        yellow.image = image
        image = CongratViewColor.Blue.getImage()
        let height = yframe.height * 2 / 3
        width = image.size.width * height / image.size.height
        bframe = CGRect(x: parent.frame.width - width, y: 0, width: width, height: height)
        blue = UIImageView(frame: middleOfRect(bframe, withSize: CGSizeZero))
        blue.image = image
        image = CongratViewColor.Purple.getImage()
        width = image.size.width * height / image.size.height
        pframe = CGRect(x: 0, y: parent.bounds.height - height, width: width, height: height)
        purple = UIImageView(frame: middleOfRect(pframe, withSize: CGSizeZero))
        purple.image = image
        super.init(frame: parent.bounds)
        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func performAnimationWithCompletion(completion: (() -> Void)?) {
        addSubview(yellow)
        addSubview(blue)
        addSubview(purple)
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations:
            { () -> Void in
                self.yellow.frame = self.yframe
            }, completion: { (finished: Bool) -> Void in
                UIView.animateWithDuration(1, delay: 0.6, options: .CurveEaseOut, animations:
                    { () -> Void in
                        self.yellow.alpha = 0
                    }, completion:
                    { (finished: Bool) -> Void in
                        self.yellow.removeFromSuperview()
                    }
                )
            }
        )
        UIView.animateWithDuration(0.4, delay: 0.8, options: .CurveEaseOut, animations:
            { () -> Void in
                self.blue.frame = self.bframe
            }, completion: { (finished: Bool) -> Void in
                UIView.animateWithDuration(1, delay: 0.6, options: .CurveEaseOut, animations:
                    { () -> Void in
                        self.blue.alpha = 0
                    }, completion:
                    { (finished: Bool) -> Void in
                        self.blue.removeFromSuperview()
                    }
                )
            }
        )
        UIView.animateWithDuration(0.4, delay: 1.6, options: .CurveEaseOut, animations:
            { () -> Void in
                self.purple.frame = self.pframe
            }, completion: { (finished: Bool) -> Void in
                UIView.animateWithDuration(1, delay: 0.6, options: .CurveEaseOut, animations:
                    { () -> Void in
                        self.purple.alpha = 0
                    }, completion:
                    { (finished: Bool) -> Void in
                        self.purple.removeFromSuperview()
                        completion?()
                    }
                )
            }
        )
    }
}

