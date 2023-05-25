//
//  ViewController.swift
//  RPSGame
//
//  Created by 林仲景 on 2023/5/10.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var computerScoreLabel: UILabel!
    @IBOutlet weak var playerScoreTextLabel: UILabel!
    @IBOutlet weak var computerScoreTextLabel: UILabel!
    @IBOutlet weak var rounds: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var battleButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var computerSignImageView: UIImageView!
    @IBOutlet weak var userSignImageView: UIImageView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet var signs: [UIButton]!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var robotLabel: UILabel!
    
    @IBOutlet weak var playAgainButton: UIButton!
    
    var timer:Timer!
    var timer2:Timer!
    var leftImageView:UIImageView!
    var rightImageView:UIImageView!
    var leftHandImageView:UIImageView!
    var rightHandImageView:UIImageView!
    
    var round = 0

    var gameStatus:GameState = .load{
        didSet{
            updateUI(gameStatus: gameStatus)
        }
    }
    
    //MARK: - 計分板
    var playerScore = 0
    var computerScore = 0

   
    //MARK: - 選擇性別
    var playerGender:gender = .none{
        didSet{
            if playerGender == .boy{
                leftImageView = playerGender.playerImage.0
                rightImageView = playerGender.playerImage.1
                view.addSubview(leftImageView)
                view.addSubview(rightImageView)
                playerLabel.text = "👦🏻"
                playerImageMoveForward()
                
            }else if playerGender == .girl{
                leftImageView = playerGender.playerImage.0
                leftImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                rightImageView = playerGender.playerImage.1
                rightImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                view.addSubview(leftImageView)
                view.addSubview(rightImageView)
                playerLabel.text = "👧🏻"
                playerImageMoveForward()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UI元件先設定看不到
        gameStatus = .load
        //建立左右手伸出去的圖片
        leftHandImageView = UIImageView(image: UIImage(named: "01"))
        rightHandImageView = UIImageView(image: UIImage(named: "02"))
        leftHandImageView.transform = CGAffineTransform(rotationAngle: .pi/180*90)
        leftHandImageView.frame = CGRect(x: -view.frame.width/2.5, y: view.frame.height/2-75, width: view.frame.width/2.5, height: 150)
        rightHandImageView.transform = CGAffineTransform.identity.rotated(by: .pi/180*(-90)).scaledBy(x: -1, y: 1)
        rightHandImageView.frame = leftHandImageView.frame.offsetBy(dx: leftHandImageView.frame.width+view.frame.size.width, dy: 0)
        view.addSubview(leftHandImageView)
        view.addSubview(rightHandImageView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //設定選擇男生女生的按鈕
        let controller = UIAlertController(title: "性別", message: "請選擇想要的小學生性別", preferredStyle: .alert)
        let boyButton = UIAlertAction(title: gender.boy.rawValue, style: .default) { _ in
            self.playerGender = .boy
        }
        controller.addAction(boyButton)
        
        
        let girlButton = UIAlertAction(title: gender.girl.rawValue, style: .default) { _ in
            self.playerGender = .girl
        }
        controller.addAction(girlButton)
        present(controller, animated: true)
    }
    
    //MARK: - 人物往前移動
    func playerImageMoveForward(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
            timer
            in
            self.leftImageView.frame.origin.x+=1
            self.rightImageView.frame.origin.x-=1
            if self.leftImageView.frame.origin.x == 0{
                //滑到定位時出現battle的按鈕
                self.battleButton.isHidden = false
                self.timer.invalidate()
            }
        }
    }
    
    //MARK: - 人物往回移動
    func playerImageMoveBackward(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true) { [self]_ in
            if leftImageView.frame.origin.x > -248{
                leftImageView.frame.origin.x-=1
                rightImageView.frame.origin.x+=1
            }
            
            if leftImageView.frame.origin.x == -248 {
                gameStatus = .ready
                timer.invalidate()
                print("人物往回移動的timer停止了")
            }
        }
    }
    
    //MARK: - 退回人物的按鈕
    @IBAction func battleButton(_ sender: UIButton) {
        //按下battle後按鈕消失
        battleButton.isHidden = true
        playerImageMoveBackward()
    }
    
    
    //MARK: - 開始選擇手勢的按鈕
    @IBAction func startButton(_ sender: UIButton) {
        gameStatus = .start
        round += 1
        rounds.text = "Round \(round)"
        showRandomSign()

    }
    
    
    
    //MARK: - 猜拳手勢一直跳
    func showRandomSign(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true){_ in
            var randomIndex1 = Int.random(in: 0...100)
            randomIndex1 = (randomIndex1+1)%3
            var randomIndex2 = Int.random(in: 0...100)
            randomIndex2 = (randomIndex2+1)%3
            self.computerSignImageView.image = UIImage(named: "\(randomIndex1)")
            self.userSignImageView.image = UIImage(named: "\(randomIndex2)")
        }
    }
    
    //MARK: - 選擇猜拳手勢
    @IBAction func chooseSigns(_ sender: UIButton) {
            timer.invalidate()
            //亂跳的猜拳手勢隱藏
            computerSignImageView.isHidden = true
            userSignImageView.isHidden = true
            //玩家可選的猜拳手勢隱藏
            signs[0].isHidden = true
            signs[1].isHidden = true
            signs[2].isHidden = true
            let userSignIndex = sender.tag
            let computerSignIndex = Int.random(in: 0...2)
            leftHandImageView.image = UIImage(named: String(format: "%02d", userSignIndex))
            rightHandImageView.image = UIImage(named: String(format: "%02d", computerSignIndex))
            let computerSign = Sign(rawValue: computerSignIndex)
            let userSign = Sign(rawValue: userSignIndex)
            print("電腦出\(computerSign!), 玩家出\(userSign!)")
            gameStatus = play(user: userSign!, opponent: computerSign!)
            handsOut()
            if computerScore == 3 || playerScore == 3{
                tryAgainButton.setTitle("獲勝的是", for: .normal)
            }else{
                tryAgainButton.setTitle("再來！", for: .normal)
            }
            
            
    }
    
   
    //MARK: - 手伸出去
    func handsOut(){
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true){ [self]_ in
            leftHandImageView.frame.origin.x += 1
            rightHandImageView.frame.origin.x -= 1
            if leftHandImageView.frame.origin.x >= 0{
                tryAgainButton.isHidden = false
                timer.invalidate()
                print("手伸出去的timer停止了")
            }
        }
    }
    
    //MARK: - 再來一次（手伸回去）
    @IBAction func tryAgain(_ sender: UIButton) {
        if playerScore<3 || computerScore<3 {
            gameStatus = .ready
        }
        
        if playerScore==3{
            gameStatus = .load
            statusLabel.isHidden = false
            statusLabel.font = UIFont.boldSystemFont(ofSize: 23)
            statusLabel.text = "🎊Winner是玩家🎊"
            timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
                timer
                in
                self.leftImageView.frame.origin.x+=1
                print(self.leftImageView.frame.origin.x)
                if self.leftImageView.frame.origin.x >= 0{
                    self.timer.invalidate()
                    self.playAgainButton.isHidden = false
                }
            }
            return
        }
        
        if computerScore==3{
            gameStatus = .load
            statusLabel.isHidden = false
            statusLabel.font = UIFont.boldSystemFont(ofSize: 23)
            statusLabel.text = "💀Winner是電腦💀"

            timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
                timer
                in
                self.rightImageView.frame.origin.x-=1
                print(self.rightImageView.frame.origin.x)
                if self.rightImageView.frame.origin.x <= self.view.frame.width-self.rightImageView.frame.width{
                    self.timer.invalidate()
                    self.playAgainButton.isHidden = false
                }
            }
            return
        }
        
        
        if leftHandImageView.frame.origin.x > -view.frame.width/2.5{
            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true){_ in
                self.leftHandImageView.frame.origin.x -= 1
                self.rightHandImageView.frame.origin.x += 1
                if self.leftHandImageView.frame.origin.x <= -self.view.frame.width/2.5{
                    self.tryAgainButton.isHidden = true
                    self.timer.invalidate()
                    print("手伸回去的timer被清除了")
                }
            }
        }
    }
    //MARK: - 重新遊戲
    @IBAction func playAgain(_ sender: UIButton) {
        if playerScore == 3{
            gameStatus = .load
            timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
                timer
                in
                self.leftImageView.frame.origin.x-=1
                if self.leftImageView.frame.origin.x <= -248{
                    self.timer.invalidate()
                    self.playAgainButton.isHidden = true
                    self.gameStatus = .ready
                    self.playerScore = 0
                    self.playerScoreLabel.text = "\(self.playerScore)"
                    self.computerScore = 0
                    self.computerScoreLabel.text = "\(self.computerScore)"
                    self.round = 0
                    self.rounds.text = "Round \(self.round)"

                }
            }
        }
        
        if computerScore == 3{
            gameStatus = .load
            timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
                timer
                in
                self.rightImageView.frame.origin.x+=1
                if self.rightImageView.frame.origin.x >= self.view.frame.width{
                    self.timer.invalidate()
                    self.playAgainButton.isHidden = true
                    self.gameStatus = .ready
                    self.playerScore = 0
                    self.playerScoreLabel.text = "\(self.playerScore)"
                    self.computerScore = 0
                    self.computerScoreLabel.text = "\(self.computerScore)"
                    self.round = 0
                    self.rounds.text = "Round \(self.round)"
                }
            }
        }
        
        if leftHandImageView.frame.origin.x > -view.frame.width/2.5{
                timer2 = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true){_ in
                self.leftHandImageView.frame.origin.x -= 1
                self.rightHandImageView.frame.origin.x += 1
                if self.leftHandImageView.frame.origin.x <= -self.view.frame.width/2.5{
                    self.tryAgainButton.isHidden = true
                    self.timer2.invalidate()
                    print("手伸回去的timer被清除了")
                }
            }
        }
    }
    
    
    func updateUI(gameStatus:GameState){
        switch gameStatus {
        case .load:
            playAgainButton.isHidden = true
            signs[0].isHidden = true
            signs[1].isHidden = true
            signs[2].isHidden = true
            playerLabel.isHidden = true
            robotLabel.isHidden = true
            playerScoreLabel.isHidden = true
            playerScoreTextLabel.isHidden = true
            computerScoreLabel.isHidden = true
            computerScoreTextLabel.isHidden = true
            statusLabel.isHidden = true
            battleButton.isHidden = true
            startButton.isHidden = true
            tryAgainButton.isHidden = true
            computerSignImageView.isHidden = true
            userSignImageView.isHidden = true
            rounds.isHidden = true
            
        case .ready:
            statusLabel.text = gameStatus.status
            rounds.isHidden = false
            signs[0].isHidden = false
            signs[1].isHidden = false
            signs[2].isHidden = false
            signs[0].isEnabled = false
            signs[1].isEnabled = false
            signs[2].isEnabled = false
            
            playerLabel.isHidden = false
            robotLabel.isHidden = false
            playerScoreLabel.isHidden = false
            playerScoreTextLabel.isHidden = false
            computerScoreLabel.isHidden = false
            statusLabel.isHidden = false
            computerScoreTextLabel.isHidden = false
            startButton.isHidden = false
            
        case .start:
            signs[0].isEnabled = true
            signs[1].isEnabled = true
            signs[2].isEnabled = true
            
            userSignImageView.isHidden = false
            computerSignImageView.isHidden = false
            startButton.isHidden = true
            
        case .win:
            playerScore+=1
            playerScoreLabel.text = "\(playerScore)"
            statusLabel.text = gameStatus.status
            
        case .lose:
            computerScore+=1
            computerScoreLabel.text = "\(computerScore)"
            statusLabel.text = gameStatus.status
        case .draw:
            statusLabel.text = gameStatus.status
        
        }
    }
    
    
    func play(user:Sign, opponent:Sign)->GameState{
        if user == opponent{ return .draw }
        
        switch user{
        case .paper:
            if opponent == .scissor{
                return .lose
            }
        case .scissor:
            if opponent == .stone{
                return .lose
            }
        case .stone:
            if opponent == .paper{
                return .lose
            }
        }
        return .win
    }
}
