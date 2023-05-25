//
//  gameState.swift
//  RPSGame
//
//  Created by 林仲景 on 2023/5/10.
//

import Foundation
import UIKit
enum gender:String{
    case none
    case boy
    case girl
    
    var playerImage:(UIImageView,UIImageView){
        switch self{
        case .boy:
            let boyImage = UIImageView(frame: CGRect(x: -248, y: 0, width: 248, height: 465))
            boyImage.image = UIImage(named: "boy")
            let girlImage = UIImageView(frame: CGRect(x: 746, y: 0, width: 248, height: 465))
            girlImage.image = UIImage(named: "girl")
            return (boyImage,girlImage)
        case .girl:
            let girlImage = UIImageView(frame: CGRect(x: -248, y: 0, width: 248, height: 465))
            girlImage.image = UIImage(named: "girl")
            let boyImage = UIImageView(frame: CGRect(x: 746, y: 0, width: 248, height: 465))
            boyImage.image = UIImage(named: "boy")
            return (girlImage,boyImage)
        default:
            return(UIImageView(),UIImageView())
        }
    }
}




enum GameState{
    case load
    case ready
    case start
    case win
    case lose
    case draw
    
    var status:String{
        switch self{
        case .ready:
            return "Ready?"
        case .win:
            return "You Win !"
        case .lose:
            return "You Lose !"
        case .draw:
            return "Draw !"
        default:
            return ""
        }
    }
}
