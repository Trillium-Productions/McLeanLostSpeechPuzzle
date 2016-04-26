//
//  viewanimating.swift
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/29/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

import UIKit

protocol DraggablePieceViewDelegate {
    func draggablePieceDidMove(piece: DraggablePieceView)
    func draggablePieceDidEndDragging(piece: DraggablePieceView)
}

let MY_2_PI: CGFloat = CGFloat(2 * M_PI)
let MY_PI: CGFloat = CGFloat(M_PI)

func angleInRange(angle: CGFloat, minimum: CGFloat, maximum: CGFloat) -> Bool {
    return minimum <= angle && angle <= maximum
}

class DraggablePieceView: UIImageView, UIGestureRecognizerDelegate {
    
    let type: FilledPiece
    let baseAngle: CGFloat
    private let tRec: UIPanGestureRecognizer
    private let rRec: UIRotationGestureRecognizer
    private let manager: MovingDelegateManager
    let preferredSize: CGSize
    
    var delegate: DraggablePieceViewDelegate?
    var isPlaced = false
    private(set) var storedTranslation: CGPoint
    private(set) var storedRotation: CGFloat
    private(set) var persistentTranslation: CGPoint
    private(set) var persistentRotation: CGFloat
    
    init(withType type: FilledPiece, puzzleContainer container: PuzzleContainerView) {
        self.type = type
        let _image = type.getImage()
        let size = container.dprov.sizeForPiece(type, withPuzzleSize: container.frame.size)
        baseAngle = DraggablePieceView.randomAngle()
        persistentRotation = baseAngle
        persistentTranslation = CGPoint.zero
        tRec = UIPanGestureRecognizer()
        tRec.maximumNumberOfTouches = Int.max
        tRec.minimumNumberOfTouches = 1
        tRec.enabled = true
        rRec = UIRotationGestureRecognizer()
        rRec.enabled = true
        storedRotation = 0
        storedTranslation = CGPoint.zero
        preferredSize = size
        manager = MovingDelegateManager()
        super.init(frame: CGRect(origin: CGPoint.zero, size: size))
        image = _image
        userInteractionEnabled = true
        tRec.addTarget(self, action: "onTranslationDetected")
        rRec.addTarget(self, action: "onRotationDetected")
        tRec.cancelsTouchesInView = false
        rRec.cancelsTouchesInView = false
        tRec.delegate = self
        rRec.delegate = self
        addGestureRecognizer(tRec)
        addGestureRecognizer(rRec)
        layer.shadowColor = UIColor.clearColor().CGColor
        layer.shadowRadius = 9
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSizeZero
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        transform = CGAffineTransformMakeRotation(baseAngle)
    }
    
    func moveToPoint(point: CGPoint, inView view: UIView, withCompletion completion: (() -> Void)?) {
        isPlaced = true
        let _point = superview!.convertPoint(point, fromView: view)
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction],
            animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                self.frame = CGRect(origin: _point, size: self.frame.size)
            }, completion: { (finished: Bool) -> Void in
                completion?()
            }
        )
    }
    
    func stopDragging() {
        tRec.enabled = true
        rRec.enabled = false
    }
    
    func angleIsInRangeOfZero(range: CGFloat) -> Bool {
        let angle = DraggablePieceView.leastEquivalentAngle(toAngle: persistentRotation)
        let half = 0.5 * range
        return angleInRange(angle, minimum: -half, maximum: half)
    }
    
    func positionInView(view: UIView) -> CGPoint {
        return view.convertPoint(frame.origin, fromView: superview!)
    }
    
    func setShadowColor(color: UIColor) {
        layer.shadowColor = color.CGColor
    }
    
    func positionInView(view: UIView, isWithinDistance distance: CGFloat, ofPoint point: CGPoint) -> Bool {
        let start = positionInView(view)
        let dist: CGFloat = sqrt(pow(start.x - point.x, 2) + pow(start.y - point.y, 2))
        return dist < distance
    }
    
    private func translateWithIncrement(increment: CGPoint) {
        let change = CGAffineTransformMakeTranslation(increment.x, increment.y)
        transform = CGAffineTransformConcat(transform, change)
    }
    
    private func incrementFromTotalTranslation(total: CGPoint) -> CGPoint {
        let change = CGPoint(x: total.x - storedTranslation.x, y: total.y - storedTranslation.y)
        storedTranslation = CGPoint(x: storedTranslation.x + change.x, y: storedTranslation.y + change.y)
        persistentTranslation = CGPoint(x: persistentTranslation.x + change.x, y: persistentTranslation.y + change.y)
        return change
    }
    
    func onTranslationDetected() {
        if tRec.state == .Began {
            manager.registerMovementStartForTransform(.Translation)
        }
        let change = incrementFromTotalTranslation(tRec.translationInView(nil))
        translateWithIncrement(change)
        if tRec.state == .Ended || tRec.state == .Cancelled || tRec.state == .Failed {
            storedTranslation = CGPoint.zero
            if manager.getPermissionForTransformCallback(.Translation) {
                delegate?.draggablePieceDidEndDragging(self)
            }
        } else {
            delegate?.draggablePieceDidMove(self)
        }
    }
    
    private func rotateWithIncrement(increment: CGFloat) {
        transform = CGAffineTransformRotate(transform, increment)
    }
    
    private func incrementFromTotalRotation(total: CGFloat) -> CGFloat {
        let change = total - storedRotation
        storedRotation += change
        persistentRotation += change
        return change
    }
    
    func onRotationDetected() {
        if rRec.state == .Began {
            manager.registerMovementStartForTransform(.Rotation)
        }
        let change = incrementFromTotalRotation(rRec.rotation)
        rotateWithIncrement(change)
        if rRec.state == .Ended || rRec.state == .Cancelled || rRec.state == .Failed {
            storedRotation = 0
            if manager.getPermissionForTransformCallback(.Rotation) {
                delegate?.draggablePieceDidEndDragging(self)
            }
        } else {
            delegate?.draggablePieceDidMove(self)
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if manager.isMovingActive {
            return bounds.contains(point)
        }
        if bounds.contains(point) {
            let scaled = DraggablePieceView.transformPoint(point, inRect: bounds.size, toRect: image!.size)
            return !AlphaGetter.isImage(image!, transparentAtPoint: scaled)
        }
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private static func transformPoint(point: CGPoint, inRect basis: CGSize, toRect target: CGSize) -> CGPoint {
        let xfac = target.width / basis.width
        let yfac = target.height / basis.height
        return CGPoint(x: xfac * point.x, y: yfac * point.y)
    }
    
    static func randomAngle() -> CGFloat {
        arc4random_stir()
        let rint = arc4random()
        return MY_2_PI * CGFloat(rint) / CGFloat(UINT32_MAX)
    }
    
    static func leastEquivalentAngle(toAngle angle: CGFloat) -> CGFloat {
        var copy = angle
        while copy < -MY_PI {
            copy += MY_2_PI
        }
        while MY_PI < copy {
            copy -= MY_2_PI
        }
        return copy
    }
}