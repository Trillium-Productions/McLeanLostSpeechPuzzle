//
//  PieceDataProvider.swift
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/20/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

import UIKit

enum FilledPiece: Int {
    case ConventionResolution = 0
    case EyewitnessAccounts = 1
    case LincolnsCorrespondence = 2
    case NewspaperReports = 3
    case NewspapersOpposedAntiSlavery = 4
    case OtherLincolnSpeeches = 5
    
    func getImage() -> UIImage {
        return UIImage(named: "\(PieceDataProvider.pieceNames[rawValue])-ImagePiece")!
    }
}

enum TitlePiece: Int {
    case ConventionResolution = 0
    case EyewitnessAccounts = 1
    case LincolnsCorrespondence = 2
    case NewspaperReports = 3
    case NewspapersOpposedAntiSlavery = 4
    case OtherLincolnSpeeches = 5
    case Radio = 6
    case Television = 7
    case TheInternet = 8
    
    func getAnswerImage() -> UIImage {
        return UIImage(named: "\(PieceDataProvider.pieceNames[rawValue])-AnswerImage")!
    }
    
    func getTitleImage() -> UIImage {
        return UIImage(named: "\(PieceDataProvider.pieceNames[rawValue])-TitlePiece")!
    }
    
    func isCorrect() -> Bool {
        return rawValue < 6
    }
    
    func getFilledPiece() -> FilledPiece? {
        if isCorrect() {
            return FilledPiece(rawValue: rawValue)
        }
        return nil
    }
}

class PieceDataProvider: NSObject {
    
    static let puzzleAspectRatio: CGFloat = 0.71041837571
    static let STANDARD_SCALE: CGFloat = 0.28424938474159
    
    static let pieceNames = [
        "ConventionResolution",
        "EyewitnessAccounts",
        "LincolnsCorrespondence",
        "NewspaperReports",
        "NewspapersOpposedAntiSlavery",
        "OtherLincolnSpeeches",
        "Radio",
        "Television",
        "TheInternet"
    ]
    
    static func randomPieces() -> [TitlePiece] {
        var source = [
            TitlePiece.ConventionResolution,
            TitlePiece.EyewitnessAccounts,
            TitlePiece.LincolnsCorrespondence,
            TitlePiece.NewspaperReports,
            TitlePiece.NewspapersOpposedAntiSlavery,
            TitlePiece.OtherLincolnSpeeches,
            TitlePiece.Radio,
            TitlePiece.Television,
            TitlePiece.TheInternet
        ]
        var shuf: [TitlePiece] = []
        for _ in 0...8 {
            let index = Int(arc4random() % UInt32(source.count))
            shuf.append(source[index])
            source.removeAtIndex(index)
        }
        return shuf
    }
    
    static func randomFilledPieces() -> [FilledPiece] {
        var source = [
            FilledPiece.ConventionResolution,
            FilledPiece.EyewitnessAccounts,
            FilledPiece.LincolnsCorrespondence,
            FilledPiece.NewspaperReports,
            FilledPiece.NewspapersOpposedAntiSlavery,
            FilledPiece.OtherLincolnSpeeches
        ]
        var shuf: [FilledPiece] = []
        for _ in 0...5 {
            let index = Int(arc4random() % UInt32(source.count))
            shuf.append(source[index])
            source.removeAtIndex(index)
        }
        return shuf
    }
    
    private let source: NSDictionary
    
    override init() {
        let path = NSBundle.mainBundle().pathForResource("puzzlepieces", ofType: "plist")
        source = NSDictionary(contentsOfFile: path!)!
        super.init()
    }
    
    func frameForPiece(type: FilledPiece) -> CGRect {
        let sub = source.objectForKey(PieceDataProvider.pieceNames[type.rawValue]) as! NSDictionary
        let xpos = CGFloat(sub.objectForKey("position.x") as! Double)
        let ypos = CGFloat(sub.objectForKey("position.y") as! Double)
        let width = CGFloat(sub.objectForKey("size.width") as! Double)
        let height = CGFloat(sub.objectForKey("size.height") as! Double)
        return CGRect(x: xpos, y: ypos, width: width, height: height)
    }
    
    func frameForPiece(type: FilledPiece, withPuzzleSize bgsize: CGSize) -> CGRect {
        let basis = frameForPiece(type)
        return CGRect(x: basis.origin.x * bgsize.width, y: basis.origin.y * bgsize.height, width: basis.width * bgsize.width, height: basis.height * bgsize.height)
    }
    
    func sizeForPiece(piece: FilledPiece, withPuzzleSize size: CGSize) -> CGSize {
        let sub = source.objectForKey(PieceDataProvider.pieceNames[piece.rawValue]) as! NSDictionary
        let pwidth = CGFloat(sub.valueForKey("size.width") as! Double)
        let pheight = CGFloat(sub.valueForKey("size.height") as! Double)
        return CGSize(width: size.width * pwidth, height: size.height * pheight)
    }
    
    func puzzleSizeWithWidth(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: width * PieceDataProvider.puzzleAspectRatio)
    }
    
    func puzzleSizeWithHeight(height: CGFloat) -> CGSize {
        return CGSize(width: height / PieceDataProvider.puzzleAspectRatio, height: height)
    }
}