//
//  PickingView.swift
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/20/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

import UIKit
import AudioToolbox

let PUZZLE_CONTAINER_SIZE = CGSize(width: 693, height: 492.5)

func vectorDistance(startingPoint start: CGPoint, endingPoint end: CGPoint) -> CGFloat {
    return sqrt(pow(start.x - end.x, 2) + pow(start.y - end.y, 2))
}

protocol PieceTrackerDelegate {
    func finalPieceWillBeAccepted()
    func finalPieceAccepted()
}

@IBDesignable class PieceTracker: UIView {
    
    private(set) var place = 0
    private(set) var phViews: [UIImageView]!
    
    @IBOutlet var topLabel: UILabel!
    
    @IBOutlet var placeholder1: UIImageView!
    @IBOutlet var placeholder2: UIImageView!
    @IBOutlet var placeholder3: UIImageView!
    @IBOutlet var placeholder4: UIImageView!
    @IBOutlet var placeholder5: UIImageView!
    @IBOutlet var placeholder6: UIImageView!
    
    var delegate: PieceTrackerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        for thing in NSBundle.mainBundle().loadNibNamed("piecetracker", owner: self, options: nil) {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
        phViews = [placeholder1, placeholder2, placeholder3, placeholder4, placeholder5, placeholder6]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for thing in NSBundle.mainBundle().loadNibNamed("piecetracker", owner: self, options: nil) {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
        phViews = [placeholder1, placeholder2, placeholder3, placeholder4, placeholder5, placeholder6]
    }
    
    func acceptPiece(pieceViewToAdd piece: TPieceView, completion: (() -> Void)?) {
        if place == 5 {
            delegate?.finalPieceWillBeAccepted()
        }
        let nView = phViews[place]
        piece.superview!.bringSubviewToFront(piece)
        UIView.animateWithDuration(0.9, animations: { () -> Void in
            piece.frame = self.convertRect(nView.frame, toView: self.superview!)
            }, completion: { (finished: Bool) -> Void in
                piece.removeFromSuperview()
                self.place++
                UIView.animateWithDuration(0.9, animations: { () -> Void in
                    nView.alpha = 1
                    }, completion: { (finished2: Bool) -> Void in
                        self.topLabel.text = "Puzzle Pieces: \(self.place) / 6"
                        completion?()
                        if self.place == 6 {
                            self.delegate?.finalPieceAccepted()
                        }
                })
        })
    }
    
    let VPADDING_FOR_SCATTER: CGFloat = 25
    
    func scatterPieces(container: PuzzleContainerView, completion: (([DraggablePieceView]) -> Void)?) {
        let basis = PieceDataProvider.randomFilledPieces()
        let fulls = [
            DraggablePieceView(withType: basis[0], puzzleContainer: container),
            DraggablePieceView(withType: basis[1], puzzleContainer: container),
            DraggablePieceView(withType: basis[2], puzzleContainer: container),
            DraggablePieceView(withType: basis[3], puzzleContainer: container),
            DraggablePieceView(withType: basis[4], puzzleContainer: container),
            DraggablePieceView(withType: basis[5], puzzleContainer: container)
        ]
        let hptop = (1024 - fulls[0].preferredSize.width - fulls[1].preferredSize.width - fulls[2].preferredSize.width) / 4
        let hpbottom = (1024 - fulls[3].preferredSize.width - fulls[4].preferredSize.width - fulls[5].preferredSize.width) / 4
        var left = hptop
        var rects: [CGRect] = [
            CGRect(x: hpbottom, y: VPADDING_FOR_SCATTER, width: fulls[0].preferredSize.width, height: fulls[0].preferredSize.height)
        ]
        left += fulls[0].preferredSize.width + hptop
        rects.append(CGRect(x: left, y: VPADDING_FOR_SCATTER, width: fulls[1].preferredSize.width, height: fulls[1].preferredSize.height))
        left += fulls[1].preferredSize.width + hptop
        rects.append(CGRect(x: left, y: VPADDING_FOR_SCATTER, width: fulls[2].preferredSize.width, height: fulls[2].preferredSize.height))
        left = hpbottom
        for i in 3...5 {
            let top = 768 - VPADDING_FOR_SCATTER - fulls[i].preferredSize.height
            rects.append(CGRect(x: left, y: top, width: fulls[i].preferredSize.width, height: fulls[i].preferredSize.height))
            left += fulls[i].preferredSize.width + hpbottom
        }
        for i in 0...5 {
            fulls[i].frame = convertRect(phViews[i].frame, toView: superview!)
            superview!.addSubview(fulls[i])
        }
        UIView.animateWithDuration(1, animations: { () -> Void in
            for i in 0...5 {
                fulls[i].frame = rects[i]
                fulls[i].setup()
            }
            }) { (finished: Bool) -> Void in
                UIView.animateWithDuration(0.6, animations: { () -> Void in
                    self.alpha = 0
                    }, completion: { (finished2: Bool) -> Void in
                        completion?(fulls)
                        self.removeFromSuperview()
                })
        }
    }
}

protocol TPieceViewDelegate {
    func tpieceWasTapped(tpiece sender: TPieceView)
}

class TPieceView: UIButton {
    
    let type: TitlePiece
    let dataProvider = (UIApplication.sharedApplication().delegate as! AppDelegate).DATA_PROVIDER
    var hasBeenTapped = false
    var delegate: TPieceViewDelegate?
    
    init(type: TitlePiece, scale: CGFloat) {
        self.type = type
        let _image = type.getTitleImage()
        let _frame = CGRect(origin: CGPoint.zero, size: CGSize(width: scale * _image.size.width, height: scale * _image.size.height))
        super.init(frame: _frame)
        setImage(_image, forState: .Normal)
        // TODO: add highlighted image
        userInteractionEnabled = true
        let rec = UITapGestureRecognizer(target: self, action: "onTap")
        rec.numberOfTapsRequired = 1
        rec.numberOfTouchesRequired = 1
        addGestureRecognizer(rec)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onTap() {
        hasBeenTapped = true
        delegate?.tpieceWasTapped(tpiece: self)
    }
    
    func goToTracker(completion: (() -> Void)?) {
        let parent = superview as! PickingView
        parent.tracker.acceptPiece(pieceViewToAdd: self) { () -> Void in
            completion?()
        }
    }
    
    func goAway(completion: (() -> Void)?) {
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            self.alpha = 0
            }) { (finished: Bool) -> Void in
                self.removeFromSuperview()
                completion?()
        }
    }
}

class PassthroughView: UIView {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return false
    }
}

@IBDesignable class PickingView: UIView, TPieceViewDelegate, PieceTrackerDelegate, DraggablePieceViewDelegate {
    
    let pieces: [TPieceView]
    var dpieces: [DraggablePieceView]!
    let dataProvider = (UIApplication.sharedApplication().delegate as! AppDelegate).DATA_PROVIDER
    
    let SCALE: CGFloat = 0.15
    let FIELD_TOP: CGFloat = 220
    let FIELD_BOTTOM: CGFloat = 625
    let PADDING: CGFloat = 10
    
    @IBOutlet weak var tracker: PieceTracker!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var puzzleContainer: PuzzleContainerView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var exitConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitButton: UIButton!
    
    var parentViewController: BeginViewController!
    
    private func create() {
        
        for thing in NSBundle.mainBundle().loadNibNamed("pickingview", owner: self, options: nil) {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
        
        var tRemWidth = bounds.width - (2 * PADDING)
        var bRemWidth = bounds.width
        var tMaxHeight: CGFloat = 0
        var bMaxHeight: CGFloat = 0
        for i in 0...4 {
            tRemWidth -= pieces[i].frame.width
            if pieces[i].frame.height > tMaxHeight {
                tMaxHeight = pieces[i].frame.height
            }
        }
        for i in 5...8 {
            bRemWidth -= pieces[i].frame.width
            if pieces[i].frame.height > bMaxHeight {
                bMaxHeight = pieces[i].frame.height
            }
        }
        let remHeight = FIELD_BOTTOM - FIELD_TOP - tMaxHeight - bMaxHeight
        let vPadding = remHeight / 3
        let hTPadding = tRemWidth / 6
        let hBPadding = bRemWidth / 5
        var left = hTPadding + PADDING
        for i in 0...4 {
            pieces[i].frame = CGRect(origin: CGPoint(x: left, y: 0.5 * (tMaxHeight - pieces[i].frame.height) + FIELD_TOP), size: pieces[i].frame.size)
            left += pieces[i].frame.width + hTPadding
        }
        let top = FIELD_TOP + 2 * vPadding + tMaxHeight + PADDING
        left = hBPadding + PADDING
        for i in 5...8 {
            pieces[i].frame = CGRect(origin: CGPoint(x: left, y: top + 0.5 * (bMaxHeight - pieces[i].frame.height)), size: pieces[i].frame.size)
            left += pieces[i].frame.width + hBPadding
        }
        for view in pieces {
            view.delegate = self
            addSubview(view)
        }
        
        question.layer.shadowColor = question.textColor.CGColor
        question.layer.shadowRadius = 6
        question.layer.shadowOffset = CGSize.zero
        let canim = CABasicAnimation(keyPath: "opacity")
        canim.fromValue = NSNumber(integer: 1)
        canim.toValue = NSNumber(float: 0.6)
        canim.duration = 0.5
        canim.repeatCount = FLT_MAX
        canim.autoreverses = true
        canim.removedOnCompletion = false
        canim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        question.layer.addAnimation(canim, forKey: nil)
        tracker.delegate = self
    }
    
    override init(frame: CGRect) {
        var _pieces: [TPieceView] = []
        for type in PieceDataProvider.randomPieces() {
            _pieces.append(TPieceView(type: type, scale: SCALE))
        }
        pieces = _pieces
        super.init(frame: frame)
        create()
    }

    required init?(coder aDecoder: NSCoder) {
        var _pieces: [TPieceView] = []
        for type in PieceDataProvider.randomPieces() {
            _pieces.append(TPieceView(type: type, scale: SCALE))
        }
        pieces = _pieces
        super.init(coder: aDecoder)
        create()
    }
    
    @IBAction func onHelpClick() {
        parentViewController.showInfo()
    }
    
    @IBAction func onExitClick() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).navigator.popToRootViewControllerAnimated(false)
    }
    
    func tpieceWasTapped(tpiece sender: TPieceView) {
        parentViewController.showAnswerForPiece(sender)
    }
    
    func finalPieceWillBeAccepted() {
        parentViewController.view.userInteractionEnabled = false
    }
    
    func finalPieceAccepted() {
        parentViewController.scroller.scrollEnabled = false
        question.layer.removeAllAnimations()
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.topLabel.alpha = 0
            self.spacer.alpha = 0
            self.question.alpha = 0
            self.infoButton.alpha = 0
            for thing in self.pieces {
                if !thing.hasBeenTapped {
                    thing.alpha = 0
                }
            }
            }) { (finished: Bool) -> Void in
                self.topLabel.removeFromSuperview()
                self.spacer.removeFromSuperview()
                self.question.removeFromSuperview()
                self.infoButton.removeFromSuperview()
                for thing in self.pieces {
                    if !thing.hasBeenTapped {
                        thing.removeFromSuperview()
                    }
                }
                UIView.animateWithDuration(0.6, animations: { () -> Void in
                    self.puzzleContainer.alpha = 1
                    }, completion: { (finished2: Bool) -> Void in
                        self.tracker.scatterPieces(self.puzzleContainer, completion: { (dpieces: [DraggablePieceView]) -> Void in
                            self.dpieces = dpieces
                            for thing in dpieces {
                                thing.delegate = self
                            }
                            self.parentViewController.view.userInteractionEnabled = true
                        })
                })
        }
    }
    
    func doCheckPopOnPiece(piece: DraggablePieceView, completion: (() -> Void)?) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let check = PoppingCheck(atCenterPoint: piece.center)
            self.addSubview(check)
            check.popApprovinglyToSize(CGSize(width: 60, height: 60), duration: 0.6, delay: 0, completion: { () -> Void in
                check.removeFromSuperview()
                completion?()
            })
        }
    }
    
    func draggablePieceDidEndDragging(piece: DraggablePieceView) {
        piece.setShadowColor(UIColor.clearColor())
        if puzzleContainer.validateDraggablePosition(piece) {
            piece.moveToPoint(puzzleContainer.originForType(piece.type, inView: puzzleContainer), inView: puzzleContainer, withCompletion:
                { () -> Void in
                    piece.isPlaced = true
                    piece.stopDragging()
                    piece.userInteractionEnabled = false
                    self.doCheckPopOnPiece(piece, completion: { () -> Void in
                        var count = 0
                        for element in self.dpieces {
                            if !element.isPlaced {
                                count++
                                element.superview!.bringSubviewToFront(element)
                            }
                        }
                        if count == 0 {
                            let iv = UIImageView(frame: self.puzzleContainer.frame)
                            iv.image = UIImage(named: "complete-puzzle")
                            iv.alpha = 0
                            self.addSubview(iv)
                            UIView.animateWithDuration(0.5, animations: { () -> Void in
                                iv.alpha = 1
                                self.exitButton.alpha = 0
                                }, completion: { (finished: Bool) -> Void in
                                    self.exitButton.hidden = true
                                    self.puzzleContainer.removeFromSuperview()
                                    for thing in self.dpieces {
                                        thing.removeFromSuperview()
                                    }
                                    self.dpieces = nil
                                    let nimage = UIImage(named: "vertical-puzzle")!
                                    let nheight: CGFloat = 768 - 50
                                    let nwidth = nimage.size.width * nheight / nimage.size.height
                                    let nleft = 1024 - nwidth - 25
                                    let nframe = CGRect(x: nleft, y: 25, width: nwidth, height: nheight)
                                    let tframe = CGRect(x: 25, y: 25, width: 1024 - 50 - nwidth, height: nheight)
                                    let cv = CongratsView(frame: tframe)
                                    cv.alpha = 0
                                    self.addSubview(cv)
                                    let congrat = CongratView(withParent: self)
                                    self.addSubview(congrat)
                                    congrat.performAnimationWithCompletion({ () -> Void in
                                        congrat.removeFromSuperview()
                                    })
                                    UIView.transitionWithView(iv, duration: 0.6, options: .LayoutSubviews, animations: { () -> Void in
                                        iv.image = UIImage(named: "vertical-puzzle")
                                        iv.frame = nframe
                                        }, completion:
                                        { (finished2: Bool) -> Void in
                                            UIView.animateWithDuration(0.6, animations: { () -> Void in
                                                cv.alpha = 1
                                                }, completion:
                                                { (finished3: Bool) -> Void in
                                                    self.exitConstraint.constant = 25
                                                    self.exitBottomConstraint.constant = 25
                                                    self.layoutIfNeeded()
                                                    self.exitButton.hidden = false;
                                                    UIView.animateWithDuration(0.4, animations:
                                                        { () -> Void in
                                                            self.exitButton.alpha = 1
                                                        }, completion:
                                                        { (finished4: Bool) -> Void in
                                                            self.parentViewController.scroller.scrollEnabled = true
                                                        }
                                                    )
                                                }
                                            )
                                    })
                            })
                        }
                    })
                }
            )
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
    
    func draggablePieceDidMove(piece: DraggablePieceView) {
        piece.superview!.bringSubviewToFront(piece)
        if puzzleContainer.validateDraggablePosition(piece) {
            piece.setShadowColor(UIColor.yellowColor())
        } else {
            piece.setShadowColor(UIColor.clearColor())
        }
    }
    
}

class CongratsView: PassthroughView {
    
    func create() {
        let arr = NSBundle.mainBundle().loadNibNamed("endtext", owner: self, options: nil)
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

class AnswerViewController: UIViewController {
    
    var instigatingPiece: TPieceView!
    var parent: BeginViewController!
    
    @IBOutlet var bgImageView: UIImageView!
    
    override func viewDidLoad() {
        bgImageView.image = instigatingPiece.type.getAnswerImage()
    }
    
    @IBAction func onSAClick() {
        parent.dismissViewControllerAnimated(true, completion: {() -> Void in
                self.parent.view.userInteractionEnabled = true
                if self.instigatingPiece.type.isCorrect() {
                    self.instigatingPiece.goToTracker(nil)
                } else {
                    self.instigatingPiece.goAway(nil)
                }
            })
    }
    
}

class PickingInfoViewController: UIViewController {
    
    var parent: BeginViewController!
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        onReturnClick()
        super.touchesEnded(touches, withEvent: event)
    }
    
    @IBAction func onReturnClick() {
        parent.dismissViewControllerAnimated(true, completion: nil)
    }
}