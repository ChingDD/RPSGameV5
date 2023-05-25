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
        //初始化alertController元件
        let controller = UIAlertController(title: "性別", message: "請選擇想要的小學生性別", preferredStyle: .alert)
        //初始化boy的按鈕
        let boyButton = UIAlertAction(title: gender.boy.rawValue, style: .default) { _ in
            self.playerGender = .boy
        }
        //controller新增boy按鈕
        controller.addAction(boyButton)
        
        //初始化girl的按鈕
        let girlButton = UIAlertAction(title: gender.girl.rawValue, style: .default) { _ in
            self.playerGender = .girl
        }
        //controller新增girl按鈕
        controller.addAction(girlButton)
        //顯示controller
        present(controller, animated: true)
    }
    
    //MARK: - 人物往前移動
    func playerImageMoveForward(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
            timer
            in
            //左邊圖片向右滑
            self.leftImageView.frame.origin.x+=1
            //右邊圖片向左滑
            self.rightImageView.frame.origin.x-=1
            //當左邊圖片的x跑到x=0時，停止timer，位移即停止
            if self.leftImageView.frame.origin.x == 0{
                //滑到定位時出現battle的按鈕
                self.battleButton.isHidden = false
                //timer停止
                self.timer.invalidate()
            }
        }
    }
    
    //MARK: - 人物往回移動
    func playerImageMoveBackward(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true) { [self]_ in
            //當左邊圖片的位置大於原來的位置時
            if leftImageView.frame.origin.x > -248{
                //左邊圖片往原來位置移動
                leftImageView.frame.origin.x-=1
                //右邊圖片往原來位置移動
                rightImageView.frame.origin.x+=1
            }
            //當左邊圖片的位置回到原來的位置時
            if leftImageView.frame.origin.x == -248 {
                //遊戲狀態變成ready
                gameStatus = .ready
                //timer停止
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
            //隨機取亂數後存到randomIndex1
            var randomIndex1 = Int.random(in: 0...100)
            //將隨意亂數變成0~2的數字
            randomIndex1 = (randomIndex1+1)%3
            //隨機取亂數後存到randomIndex2
            var randomIndex2 = Int.random(in: 0...100)
            //將隨意亂數變成0~2的數字
            randomIndex2 = (randomIndex2+1)%3
            //得到指定的圖片
            self.computerSignImageView.image = UIImage(named: "\(randomIndex1)")
            self.userSignImageView.image = UIImage(named: "\(randomIndex2)")
        }
    }
    
    //MARK: - 選擇猜拳手勢
    @IBAction func chooseSigns(_ sender: UIButton) {
        //將亂跳的手勢timer停止
        timer.invalidate()
        //亂跳的猜拳手勢隱藏
        computerSignImageView.isHidden = true
        userSignImageView.isHidden = true
        //玩家可選的猜拳手勢隱藏
        signs[0].isHidden = true
        signs[1].isHidden = true
        signs[2].isHidden = true
        //利用tag偵測按的手勢按鈕是哪個，得到對應的整數
        let userSignIndex = sender.tag
        //電腦隨機出手勢
        let computerSignIndex = Int.random(in: 0...2)
        //將各自得到的整數傳入參數，得到照片出拳的手勢照片
        leftHandImageView.image = UIImage(named: String(format: "%02d", userSignIndex))
        rightHandImageView.image = UIImage(named: String(format: "%02d", computerSignIndex))
        //將各自對應手勢的整數傳入rawValue，可以得到手勢的字串
        let computerSign = Sign(rawValue: computerSignIndex)
        let userSign = Sign(rawValue: userSignIndex)
        print("電腦出\(computerSign!), 玩家出\(userSign!)")
        //將得到的手勢字串進行比較，得到輸贏狀態
        gameStatus = play(user: userSign!, opponent: computerSign!)
        //將手勢照片伸出去
        handsOut()
        //有一邊得到三分時，改變按鈕的字型
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
        //如果玩家勝利
        if playerScore==3{
            gameStatus = .load
            statusLabel.isHidden = false
            statusLabel.font = UIFont.boldSystemFont(ofSize: 23)
            statusLabel.text = "🎊Winner是玩家🎊"
            //勝利的玩家圖片往前出現
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
        //如果電腦贏
        if computerScore==3{
            gameStatus = .load
            statusLabel.isHidden = false
            //改變狀態Label的字
            statusLabel.font = UIFont.boldSystemFont(ofSize: 23)
            statusLabel.text = "💀Winner是電腦💀"
            //勝利的電腦圖片往前出現
            timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
                timer
                in
                self.rightImageView.frame.origin.x-=1
                print(self.rightImageView.frame.origin.x)
                //如果右手的x < 整個View的寬度-右手圖片的寬度(此時右手的最底部會剛好貼到邊邊)
                if self.rightImageView.frame.origin.x <= self.view.frame.width-self.rightImageView.frame.width{
                    //timer停止運作
                    self.timer.invalidate()
                    //再玩一次按鈕出現
                    self.playAgainButton.isHidden = false
                }
            }
            return
        }
        
        //寫後面是因為，如果有人勝利，就會return而不會跑到這邊。如果沒人贏，表示這時候伸出去的是兩隻手，所以要把兩隻手伸回來。
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
        //如果玩家得3分
        if playerScore == 3{
            gameStatus = .load
            //左邊的玩家圖片收回去
            timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
                timer
                in
                self.leftImageView.frame.origin.x-=1
                if self.leftImageView.frame.origin.x <= -248{
                    self.timer.invalidate()
                    //再玩一次按鈕隱藏
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
        //如果電腦得3分
        if computerScore == 3{
            gameStatus = .load
            //右邊的玩家圖片收回去
            timer = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true){
                timer
                in
                self.rightImageView.frame.origin.x+=1
                if self.rightImageView.frame.origin.x >= self.view.frame.width{
                    self.timer.invalidate()
                    //再玩一次按鈕隱藏
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
        //有人勝出時，此時雙手會留在畫面上，因此重新玩時要把雙手叫回去
        //若左手的距離大於原本位置
        if leftHandImageView.frame.origin.x > -view.frame.width/2.5{
                timer2 = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true){_ in
                //左手圖片往後退
                self.leftHandImageView.frame.origin.x -= 1
                //右手圖片往後退
                self.rightHandImageView.frame.origin.x += 1
                //如果左手圖片位置回到原本位置
                if self.leftHandImageView.frame.origin.x <= -self.view.frame.width/2.5{
                    //timer結束
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
