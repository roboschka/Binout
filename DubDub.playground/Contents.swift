//: A SpriteKit based Playground

import PlaygroundSupport
import UIKit
import SpriteKit
import GameplayKit
import SceneKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

let BallCategory   : UInt32 = 0x1 << 1
let BottomCategory : UInt32 = 0x1 << 2
let BlockCategory  : UInt32 = 0x1 << 3
let PaddleCategory : UInt32 = 0x1 << 4
let BorderCategory : UInt32 = 0x1 << 5

let sceneView = SKView(frame: CGRect(x:0 , y: 0, width: 768, height: 1024))
let catalogview = UIScrollView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
catalogview.setContentOffset(CGPoint(x: 1000, y: 1024), animated: true)

let backButton = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 20))

let background1 = UIButton(frame: CGRect(x: 60, y: 60, width: 200, height: 250))
let bgImage1 = UIImageView(image: UIImage(named: "paddle"))
bgImage1.frame = CGRect(x: 0, y: 0, width: 200, height: 250)
catalogview.addSubview(background1)
background1.addSubview(bgImage1)

let background2 = UIButton(frame: CGRect(x: 280, y: 60, width: 200, height: 250))
let bgImage2 = UIImageView(image: UIImage(named: "paddle"))
bgImage2.frame = CGRect(x: 0, y: 0, width: 200, height: 250)
catalogview.addSubview(background2)
background2.addSubview(bgImage2)


let background3 = UIButton(frame: CGRect(x: 500, y: 60, width: 200, height: 250))
let bgImage3 = UIImageView(image: UIImage(named: "paddle"))
bgImage3.frame = CGRect(x: 0, y: 0, width: 200, height: 250)
catalogview.addSubview(background3)
background3.addSubview(bgImage3)

description1()
description2()

func description1(){
    //Glodok
    let title = UILabel(frame: CGRect(x: 60, y: 280, width: 200, height: 100))
    let desc = UILabel(frame: CGRect(x: 0, y: 35, width: 200, height: 200))
    title.text = "Glodok Market"
    title.font = UIFont(name: "Avenir-Heavy", size: 20)
    desc.font = UIFont(name: "Avenir", size: 12)
    desc.text = "A local traditional market located in Indonesia's biggest chinatown: Glodok, Jakarta. Glodok Market sells a bunch of things ranging from fashionable clothes to traditional medicine. But they're most known for their huge variety of chinese cuisine."
    desc.lineBreakMode = NSLineBreakMode.byWordWrapping
    desc.numberOfLines = 0
        

    catalogview.addSubview(title)
    title.addSubview(desc)
}

func description2(){
    //Floating Market
    let title = UILabel(frame: CGRect(x: 280, y: 280, width: 200, height: 100))
    let desc = UILabel(frame: CGRect(x: 0, y: 35, width: 200, height: 200))
    
    title.text = "Floating Market"
    title.font = UIFont(name: "Avenir-Heavy", size: 20)
    desc.font = UIFont(name: "Avenir", size: 12)
    
    desc.text = "A local traditional market located in Indonesia's biggest chinatown: Glodok, Jakarta. Glodok Market sells a bunch of things ranging from fashionable clothes to traditional medicine. But they're most known for their huge variety of chinese cuisine."
    
    desc.lineBreakMode = NSLineBreakMode.byWordWrapping
    desc.numberOfLines = 0
    
    catalogview.addSubview(title)
    title.addSubview(desc)
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var coinPoints: Int = 0
    var catalogTouched: Bool = false
    
    var isFingerOnPaddle = false
    var coins = SKLabelNode(fontNamed: "SF Pro Rounded")
    
    private var label : SKLabelNode!
    private var spinnyNode : SKShapeNode!
    
    var borderBg: SKSpriteNode!
    
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
    WaitingForTap(scene: self),
    Playing(scene: self),
    GameOver(scene: self)])

    
    var gameWon : Bool = false {
      didSet {
        let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
        let textureName = gameWon ? "YouWon" : "GameOver"
        let texture = SKTexture(imageNamed: textureName)
        let actionSequence = SKAction.sequence([SKAction.setTexture(texture),
          SKAction.scale(to: 1.0, duration: 0.25)])
          
        run(gameWon ? gameWonSound : gameOverSound)
        gameOver.run(actionSequence)
      }
    }
    
    //MARK: Music
    let blipSound = SKAction.playSoundFileNamed("pongblip", waitForCompletion: false)
    let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
    let bambooBreakSound = SKAction.playSoundFileNamed("BambooBreak", waitForCompletion: false)
    let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
          firstBody = contact.bodyA
          secondBody = contact.bodyB
        } else {
          firstBody = contact.bodyB
          secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
            gameState.enter(GameOver.self)
            gameWon = false
        }
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
            run(bambooBreakSound)
            breakBlock(secondBody.node!)
            coinPoints += Int.random(in: 3...5)
            coins.text = String(coinPoints)
            
            print(coinPoints)
            if isGameWon() {
              gameState.enter(GameOver.self)
              gameWon = true
            }
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BorderCategory {
          run(blipSound)
        }
              
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory {
          run(blipPaddleSound)
        }
    }
    
    
    override func didMove(to view: SKView) {
        catalogview.isHidden = true
        
        background1.addTarget(self, action: #selector(imagePressed), for: .touchUpInside)
        
        
        backButton.setTitle("Back", for: .normal)
        backButton.backgroundColor = .black
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        
        
        
        coins.text = String(coinPoints)
        coins.fontSize = 36
        coins.fontColor = SKColor.white
        coins.position = CGPoint(x: frame.width * 0.9, y: frame.height * 0.92)
        coins.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right

        addChild(coins)
        
        goToCatalogButton()
        
        
        let border = childNode(withName: "collision_test") as! SKSpriteNode
        let borderBody = SKPhysicsBody(edgeLoopFrom: border.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        borderBg = border
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
        let ball = childNode(withName: "ball") as! SKSpriteNode
        
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        ball.addChild(trail)
        
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        
        
        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        
        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        borderBody.categoryBitMask = BorderCategory
        
        ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory | BorderCategory | PaddleCategory
        
        
        //Bamboo Blocks
        let numberOfBlocks = 6
        let blockWidth = SKSpriteNode(imageNamed: "block.png").size.width
        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
        // 2.
        let xOffset = (frame.width - totalBlocksWidth) / 2
        // 3.
        for i in 0..<numberOfBlocks {
          let block = SKSpriteNode(imageNamed: "block.png")
          block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i) + 0.5) * blockWidth,
                                   y: frame.height * 0.7)
          
          block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
          block.physicsBody!.allowsRotation = false
          block.physicsBody!.friction = 0.0
          block.physicsBody!.affectedByGravity = false
          block.physicsBody!.isDynamic = false
          block.name = BlockCategoryName
          block.physicsBody!.categoryBitMask = BlockCategory
          block.zPosition = 2
          addChild(block)
        }
        
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        gameMessage.zPosition = 4
        gameMessage.setScale(1.0)
        addChild(gameMessage)

        gameState.enter(WaitingForTap.self)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            if touch == touches.first {
                enumerateChildNodes(withName: "//*", using: {(node, stop) in
                    if node.name == "catalogButton" {
                        if node.contains(touch.location(in: self)) {
                            self.gameState.enter(WaitingForTap.self)
                            catalogview.isHidden = false
                            self.catalogTouched = true
                        }
                    }
                })
            }
        }
        
        switch gameState.currentState {
        case is WaitingForTap:
            if catalogTouched {
                print("catalogue is active")
            }
            else {
              gameState.enter(Playing.self)
              isFingerOnPaddle = true
            }
            
        case is Playing:
          let touch = touches.first
          let touchLocation = touch!.location(in: self)
          if let body = physicsWorld.body(at: touchLocation) {
            if body.node!.name == PaddleCategoryName {
              isFingerOnPaddle = true
            }
          }
            
        case is GameOver:
            let newScene = GameScene(fileNamed:"GameScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
            
        default:
          break
        }
        
        //click button
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPaddle {
          let touch = touches.first
          let touchLocation = touch!.location(in: self)
          let previousLocation = touch!.previousLocation(in: self)
          
          let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
          
          var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
          
          paddleX = max(paddleX, paddle.size.width/2)
          paddleX = min(paddleX, size.width - paddle.size.width/2)
          
          paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        gameState.update(deltaTime: currentTime)
    }
    
    //MARK: Helpers
    
    @objc func backButtonPressed(_ sender: UIButton!){
        catalogTouched = false
        catalogview.isHidden = true
    }
    
    @objc func imagePressed(_ sender: UIButton!) {
        print("pressed Glodok")
        borderBg.texture = SKTexture(imageNamed: "ball")
    }
    
    func goToCatalogButton(){
        let catalogButton = SKSpriteNode(imageNamed: "ball")
        catalogButton.name = "catalogButton"
        catalogButton.size = CGSize(width: 50, height: 50)
        catalogButton.position = CGPoint(x: frame.width * 0.1, y: frame.height * 0.94)
        addChild(catalogButton)
    }
    
    func breakBlock(_ node: SKNode){
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
          SKAction.removeFromParent()]))
        node.removeFromParent()
    }
    
    func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
      let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
      return (rand) * (to - from) + from
    }
    
    func isGameWon() -> Bool {
      var numberOfBricks = 0
      self.enumerateChildNodes(withName: BlockCategoryName) {
        node, stop in
        numberOfBricks = numberOfBricks + 1
      }
      return numberOfBricks == 0
    }
}



//MARK: Game States
class WaitingForTap: GKState {
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
  }
  
  override func didEnter(from previousState: GKState?) {
    let scale = SKAction.scale(to: 1.0, duration: 0.25)
    scene.childNode(withName: GameMessageName)!.run(scale)
    
  }
  
  override func willExit(to nextState: GKState) {
    if nextState is Playing {
      let scale = SKAction.scale(to: 0, duration: 0.4)
      scene.childNode(withName: GameMessageName)!.run(scale)
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is Playing.Type
  }

}

class Playing: GKState {
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    if previousState is WaitingForTap {
      let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
      ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: randomDirection()))
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
    
    let maxSpeed: CGFloat = 400.0
    
    let xSpeed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx)
    let ySpeed = sqrt(ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
    
    let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
    
    if xSpeed <= 10.0 {
      ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: 0.0))
    }
    if ySpeed <= 10.0 {
      ball.physicsBody!.applyImpulse(CGVector(dx: 0.0, dy: randomDirection()))
    }
    
    if speed > maxSpeed {
      ball.physicsBody!.linearDamping = 0.4
    }
    else {
      ball.physicsBody!.linearDamping = 0.0
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type
  }
  
  func randomDirection() -> CGFloat {
    let speedFactor: CGFloat = 3.0
    if scene.randomFloat(from: 0.0, to: 100.0) >= 50 {
      return -speedFactor
    } else {
      return speedFactor
    }
  }
}

class GameOver: GKState {
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    if previousState is Playing {
      let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
      ball.physicsBody!.linearDamping = 1.0
      scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is WaitingForTap.Type
  }
}

if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    catalogview.backgroundColor = .white
    catalogview.addSubview(backButton)
    //add catalog
    sceneView.addSubview(catalogview)
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundPage.current.liveView = sceneView
