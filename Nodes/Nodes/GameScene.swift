//
//  GameScene.swift
//  Nodes
//
//  Created by Bryce Daniel on 12/6/14.
//  Copyright (c) 2014 Bryce Daniel. All rights reserved.
//

/* Todo:
* Frenzy Bonus


*/


import SpriteKit
import UIKit
import Foundation


// Object Variables
var background: SKSpriteNode!
var timerLabel: SKLabelNode!
var scoreLabel: SKLabelNode!
var highScoreLabel: SKLabelNode!
var centerRing: SKSpriteNode!
var nodeBall: SKSpriteNode!
var colorBar: SKSpriteNode!
var nodeSet: SKNode!
var nodeColor: Int!
var centerRingColor: Int!
var replayButton: SKSpriteNode!
var pauseButton: SKSpriteNode!
var nodePowerup: SKSpriteNode!
var monoModeIndicator: SKSpriteNode!
var slowTimeIndicator: SKSpriteNode!
var clock: SKNode!
var frenzySet: SKNode!

// Colors
let redColor = SKColor(red: 1, green: 28/255, blue: 105/255, alpha: 1)
let greenColor = SKColor(red: 166/255, green: 232/255, blue: 99/255, alpha: 1)
let blueColor = SKColor(red: 62/225, green: 197/255, blue: 255/255, alpha: 1)

// GameStates
var score: Int!
var highScore = NSInteger()
var frenzyBonus: Int!
var frenzyModeOn: Bool = false
var haveMPowerup: Bool!
var haveTPowerup: Bool!
//var colorBarProgress: Int!
var timer: Int!
var gameOver = false
var gameBegan = false

// Random Variable
var columnMultiplier: CGFloat!
var rowMultiplier: CGFloat!
var sizeMultiplier: CGFloat!

// AI variables
var direction: CGVector!
var randomDX: Int!
var randomDY: Int!
var circlePath: CGPathRef!

var invisibleControllerSprite = SKSpriteNode()

// For Flicks
struct TouchInfo {
    var location:CGPoint
    var time:NSTimeInterval
}
var selectedNode:SKSpriteNode?
var history:[TouchInfo]?

// Collision Contact Categories
let nodeCategory: UInt32 = 1 << 0
let worldCategory: UInt32 = 1 << 1
//let anchorCategory: UInt32 = 1 << 2




class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.size = view.bounds.size
        self.backgroundColor = UIColor.blackColor()
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame)
        self.physicsBody?.categoryBitMask = worldCategory
        
        // Setup Methods
        setupBackground()
        setupScoreLabel()
        setupHighScoreLabel()
        
        setupCenterRing()
        spawnNodes()
        spawnPowerups()
        setupPauseButton()
        
        //        setupColorBar()
        
        nodeSet = SKNode()
        self.addChild(nodeSet)
        
        clock = SKNode()
        self.addChild(clock)
        
        frenzySet = SKNode()
        self.addChild(frenzySet)
        
        setupTimeLabel()
        
        randomlyChangeRingColor()
        
        frenzyBonus = 0
        
        setupMonoIndicator()
        
        setupSlowTimeIndicator()
        
    }
    
    // Add Background
    func setupBackground() {
        background = SKSpriteNode(imageNamed: "background")
        background.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        background.size = CGSizeMake(background.frame.width, background.frame.height)
        background.zPosition = -100
        self.addChild(background)
    }
    
    // Create Score label
    func setupScoreLabel() {
        score = 0
        scoreLabel = SKLabelNode(fontNamed: "Avenir Next")
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.fontSize = 22
        scoreLabel.position = CGPointMake(self.frame.width / 10, self.frame.height / 1.05)
        scoreLabel.text = String(score)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
    }
    
    func setupHighScoreLabel() {
        if highScore <= score {
            highScore = score
        }
        highScoreLabel = SKLabelNode(fontNamed: "Avenir Next")
        highScoreLabel.fontColor = UIColor.blackColor()
        highScoreLabel.alpha = 0.5
        highScoreLabel.fontSize = 22
        highScoreLabel.position = CGPointMake(self.frame.width / 10, self.frame.height / 1.1)
        highScoreLabel.text = String(highScore)
        highScoreLabel.zPosition = 100
        self.addChild(highScoreLabel)
    }
    
    // Function for updating the high score
    func updateHighScore() {
        if highScore <= score {
            highScore = score
            highScoreLabel.text = String(highScore)
            highScoreLabel.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration:NSTimeInterval(0.1)), SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))]))
        }
    }
    
    
    
    func setupTimeLabel(){
        timer = 90
        timerLabel = SKLabelNode(fontNamed: "Avenir Next")
        timerLabel.fontColor = UIColor.blackColor()
        timerLabel.fontSize = 22
        timerLabel.position = CGPointMake(self.frame.width / 2, self.frame.height / 1.05)
        timerLabel.text = String(timer)
        timerLabel.zPosition = 100
        clock.addChild(timerLabel)
        runTimer()
    }
    
    
    func runTimer(){
        if timer > 0 {
            let delay = SKAction.waitForDuration(1)
            let decriment = SKAction.runBlock { () -> Void in
                timer = timer - 1
                timerLabel.text = String(timer)
            }
            let decrimentThenDelay = SKAction.sequence([decriment, delay])
            let decrimentThenDelayForTimer = SKAction.repeatAction(decrimentThenDelay, count: timer)
            clock.runAction(decrimentThenDelayForTimer, completion: {
                // Call game over function
                gameOver = true
                self.setupReplayButton()
                print("game over")
            })
            
        }
    }
    
    func setupCenterRing(){
        centerRing = SKSpriteNode(imageNamed: "centerRing")
        centerRing.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        centerRing.size = CGSizeMake(centerRing.frame.width, centerRing.frame.height)
        centerRing.zPosition = -50
        centerRing.colorBlendFactor = 1.0
        self.addChild(centerRing)
        
        centerRingColor = Int(arc4random_uniform(3))
        switch centerRingColor {
        case 0:
            centerRing.name = "ringR"
            centerRing.color = redColor
        case 1:
            centerRing.name = "ringB"
            centerRing.color = blueColor
        case 2:
            centerRing.name = "ringG"
            centerRing.color = greenColor
        default:
            break
        }
        
    }
    
    func randomlyChangeRingColor() {
        var interval = Int(arc4random_uniform(5) + 5)
        let waitForInterval = SKAction.waitForDuration(NSTimeInterval(interval))
        let changeColor = SKAction.runBlock{ () -> Void in
            
            centerRingColor = Int(arc4random_uniform(3))
            switch centerRingColor {
            case 0:
                centerRing.name = "ringR"
                centerRing.color = redColor
            case 1:
                centerRing.name = "ringB"
                centerRing.color = blueColor
            case 2:
                centerRing.name = "ringG"
                centerRing.color = greenColor
            default:
                break
            }
        }
        let waitThenChange = SKAction.sequence([waitForInterval, changeColor])
        let changeForever = SKAction.repeatActionForever(waitThenChange)
        centerRing.runAction(changeForever)
        
    }
    
    func setupReplayButton() {
        replayButton = SKSpriteNode(imageNamed: "refreshButton")
        replayButton.size = CGSizeMake(replayButton.size.width , replayButton.size.height)
        replayButton.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        replayButton.zPosition = 100
        replayButton.name = "replayButton"
        
        self.addChild(replayButton)
    }
    
    func resetScene(){
        monoModeIndicator.removeFromParent()
        slowTimeIndicator.removeFromParent()
        setupMonoIndicator()
        setupSlowTimeIndicator()
        replayButton.removeFromParent()
        invisibleControllerSprite.removeFromParent()
        gameOver = false
        
        let delay = SKAction.waitForDuration(2)
        nodeSet.runAction(delay, completion: {
            nodeSet.removeAllChildren()
        })
        let delay2 = SKAction.waitForDuration(2)
        nodeSet.runAction(delay2, completion: {
            scoreLabel.removeFromParent()
            timerLabel.removeFromParent()
            self.setupScoreLabel()
            self.setupTimeLabel()
            timerLabel.text = String(timer)
            self.spawnNodes()
            self.spawnPowerups()
            frenzyBonus = 0
            clock.paused = false
            timerLabel.fontColor = UIColor.blackColor()
            timerLabel.fontSize = 22
        })
        
        
        for var index = 0; index < nodeSet.children.count; ++index{
            (nodeSet.children[index] as SKSpriteNode).name = "Scored"
        }
        
    }
    
    func setupSlowTimeIndicator(){
        slowTimeIndicator = SKSpriteNode(imageNamed: "nodeT")
        //        slowTimeIndicator.anchorPoint = CGPointMake(0, 0)
        slowTimeIndicator.position = CGPointMake(self.frame.width/15, self.frame.height / 10)
        slowTimeIndicator.size = CGSizeMake(slowTimeIndicator.frame.width / 1.5, slowTimeIndicator.frame.height / 1.5)
        slowTimeIndicator.zPosition = 199
        slowTimeIndicator.alpha = 0.1
        slowTimeIndicator.name = "slowTimeIndicator"
        slowTimeIndicator.physicsBody = SKPhysicsBody(circleOfRadius: slowTimeIndicator.frame.width / 2)
        slowTimeIndicator.physicsBody?.dynamic = false
        self.addChild(slowTimeIndicator)
    }
    
    func setupMonoIndicator(){
        monoModeIndicator = SKSpriteNode(imageNamed: "nodeM")
        //        monoModeIndicator.anchorPoint = CGPointMake(0, 0)
        monoModeIndicator.position = CGPointMake(self.frame.width/15, self.frame.height / 30)
        monoModeIndicator.size = CGSizeMake(monoModeIndicator.frame.width / 1.5, monoModeIndicator.frame.height / 1.5)
        monoModeIndicator.alpha = 0.1
        monoModeIndicator.zPosition = 200
        monoModeIndicator.name = "monoModeIndicator"
        monoModeIndicator.physicsBody = SKPhysicsBody(circleOfRadius:monoModeIndicator.frame.width / 2)
        monoModeIndicator.physicsBody?.dynamic = false
        self.addChild(monoModeIndicator)
    }
    
    
    func setupPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: "pauseButton")
        pauseButton.size = CGSizeMake(pauseButton.size.width / 1.5 , pauseButton.size.height / 1.5)
        pauseButton.position = CGPointMake(self.frame.width / 1.05, self.frame.height / 1.03)
        pauseButton.zPosition = 201
        pauseButton.name = "pauseButton"
        
        self.addChild(pauseButton)
    }
    
    // Create Nodes
    func setupNodes(){
        
        nodeBall = SKSpriteNode(imageNamed: "nodeW")
        
        do {
            columnMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(columnMultiplier <= 0.1 || columnMultiplier >= 0.95)
        
        do {
            rowMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(rowMultiplier <= 0.1 || rowMultiplier >= 0.95)
        
        do {
            sizeMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(sizeMultiplier <= 0.5 || sizeMultiplier >= 1.0)
        
        nodeBall.size = CGSizeMake(sizeMultiplier * nodeBall.frame.width / 2, sizeMultiplier *  nodeBall.frame.height / 2)
        
        nodeBall.position = CGPointMake((columnMultiplier * self.frame.width), (rowMultiplier * self.frame.size.height))
        nodeBall.physicsBody = SKPhysicsBody(circleOfRadius: nodeBall.frame.height/2)
        nodeBall.physicsBody?.categoryBitMask = nodeCategory
        nodeBall.physicsBody?.contactTestBitMask = nodeCategory
        nodeBall.physicsBody?.dynamic = true
        nodeBall.physicsBody?.affectedByGravity = false
        nodeBall.colorBlendFactor = 1
        nodeBall.physicsBody?.mass = sizeMultiplier
        nodeBall.physicsBody?.restitution = 0.3
        nodeBall.physicsBody?.friction = 0.1
        
        
        nodeColor = Int(arc4random_uniform(3))
        switch nodeColor {
        case 0:
            nodeBall.color = redColor
            nodeBall.name = "nodeR"
            if frenzyModeOn == false {
                nodeSet.addChild(nodeBall)
            } else {
                frenzySet.addChild(nodeBall)
            }
            var signX = Int(arc4random_uniform(2))
            var signY = Int(arc4random_uniform(2))
            
            if signX == 0 {
                randomDX = Int(arc4random_uniform(100))
            } else {
                randomDX = Int(arc4random_uniform(100)) * -1
            }
            if signY == 0 {
                randomDY = Int(arc4random_uniform(100))
            } else {
                randomDY = Int(arc4random_uniform(100)) * -1
            }
            nodeBall.physicsBody?.velocity = CGVector(dx: randomDX, dy: randomDY)
            /*
            circlePath = CGPathCreateWithEllipseInRect(CGRectMake(0 , 0, 300, 300), nil)
            let followPath = SKAction.followPath(circlePath, asOffset: false, orientToPath: true, duration: 10)
            let followPathForever = SKAction.repeatActionForever(followPath)
            node.runAction(followPathForever)
            */
            
        case 1:
            nodeBall.color = blueColor
            nodeBall.name = "nodeB"
            if frenzyModeOn == false {
                nodeSet.addChild(nodeBall)
            } else {
                frenzySet.addChild(nodeBall)
            }
            var signX = Int(arc4random_uniform(2))
            var signY = Int(arc4random_uniform(2))
            
            if signX == 0 {
                randomDX = Int(arc4random_uniform(100))
            } else {
                randomDX = Int(arc4random_uniform(100)) * -1
            }
            if signY == 0 {
                randomDY = Int(arc4random_uniform(100))
            } else {
                randomDY = Int(arc4random_uniform(100)) * -1
            }
            nodeBall.physicsBody?.velocity = CGVector(dx: randomDX, dy: randomDY)
            
            
        case 2:
            nodeBall.color = greenColor
            nodeBall.name = "nodeG"
            if frenzyModeOn == false {
                nodeSet.addChild(nodeBall)
            } else {
                frenzySet.addChild(nodeBall)
            }
            var signX = Int(arc4random_uniform(2))
            var signY = Int(arc4random_uniform(2))
            
            if signX == 0 {
                randomDX = Int(arc4random_uniform(100))
            } else {
                randomDX = Int(arc4random_uniform(100)) * -1
            }
            if signY == 0 {
                randomDY = Int(arc4random_uniform(100))
            } else {
                randomDY = Int(arc4random_uniform(100)) * -1
            }
            nodeBall.physicsBody?.velocity = CGVector(dx: randomDX, dy: randomDY)
        default:
            break
        }
        
        
        nodeBall.alpha = 0
        let scale0 = SKAction.scaleTo(0, duration: 0)
        nodeBall.runAction(scale0)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.2)
        let scaleIn = SKAction.scaleTo(1.0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)
        let fadeAndScale = SKAction.group([fadeIn,scaleIn])
        nodeBall.runAction(fadeAndScale)
        
        let rangeForOrientation = SKRange(constantValue: CGFloat(M_2_PI*7))
        nodeBall.constraints = [SKConstraint.orientToNode(invisibleControllerSprite, offset: rangeForOrientation)]
        
    }
    
    // Spawn Nodes
    func spawnNodes(){
        let spawn = SKAction.runBlock { () -> Void in
            self.setupNodes()
            gameBegan = true
        }
        
        
        let delay = SKAction.waitForDuration(1.5)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        invisibleControllerSprite.size = CGSizeMake(0, 0)
        self.addChild(invisibleControllerSprite)
        
        
    }
    
    // Create Powerups
    func setupPowerups(){
        var powerupType = Int(arc4random_uniform(2))
        switch powerupType {
        case 0:
            nodePowerup = SKSpriteNode(imageNamed: "nodeM")
            nodePowerup.name = "nodeM"
        default:
            nodePowerup = SKSpriteNode(imageNamed: "nodeT")
            nodePowerup.name = "nodeT"
        }
        
        do {
            columnMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(columnMultiplier <= 0.1 || columnMultiplier >= 0.95)
        
        do {
            rowMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(rowMultiplier <= 0.1 || rowMultiplier >= 0.95)
        
        do {
            sizeMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(sizeMultiplier <= 0.5 || sizeMultiplier >= 1.0)
        
        nodePowerup.size = CGSizeMake(sizeMultiplier * nodePowerup.frame.width, sizeMultiplier *  nodePowerup.frame.height)
        
        nodePowerup.position = CGPointMake((columnMultiplier * self.frame.width), (rowMultiplier * self.frame.size.height))
        nodePowerup.physicsBody = SKPhysicsBody(circleOfRadius: nodePowerup.frame.height/2)
        nodePowerup.physicsBody?.categoryBitMask = nodeCategory
        nodePowerup.physicsBody?.contactTestBitMask = nodeCategory
        nodePowerup.physicsBody?.dynamic = true
        nodePowerup.physicsBody?.affectedByGravity = false
        nodePowerup.physicsBody?.mass = sizeMultiplier
        nodePowerup.physicsBody?.restitution = 0.3
        nodePowerup.physicsBody?.friction = 0.1
        
        
        //        nodeBall.color = redColor
        nodeSet.addChild(nodePowerup)
        var signX = Int(arc4random_uniform(2))
        var signY = Int(arc4random_uniform(2))
        
        if signX == 0 {
            randomDX = Int(arc4random_uniform(100))
        } else {
            randomDX = Int(arc4random_uniform(100)) * -1
        }
        if signY == 0 {
            randomDY = Int(arc4random_uniform(100))
        } else {
            randomDY = Int(arc4random_uniform(100)) * -1
        }
        nodePowerup.physicsBody?.velocity = CGVector(dx: randomDX, dy: randomDY)
        
        
        nodePowerup.alpha = 0
        let scale0 = SKAction.scaleTo(0, duration: 0)
        nodePowerup.runAction(scale0)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.2)
        let scaleIn = SKAction.scaleTo(1.0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)
        let fadeAndScale = SKAction.group([fadeIn,scaleIn])
        nodePowerup.runAction(fadeAndScale)
        
        let rangeForOrientation = SKRange(constantValue: CGFloat(M_2_PI*7))
        nodePowerup.constraints = [SKConstraint.orientToNode(invisibleControllerSprite, offset: rangeForOrientation)]
        
    }
    
    func spawnPowerups(){
        let spawn = SKAction.runBlock { () -> Void in
            self.setupPowerups()
        }
        
        let randomTime = Int(arc4random_uniform(20)+20)
        let delay = SKAction.waitForDuration(NSTimeInterval(randomTime))
        let spawnThenDelay = SKAction.sequence([delay, spawn])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        
    }
    
    func updateScore() {
        
        // Frenzy Mode off
        for var index = 0; index < nodeSet.children.count; ++index{
            
            if ((nodeSet.children[index].position.x > centerRing.frame.minX)
                && (nodeSet.children[index].position.x < centerRing.frame.maxX)
                && (nodeSet.children[index].position.y > centerRing.frame.minY)
                && (nodeSet.children[index].position.y < centerRing.frame.maxY)) {
                    
                    // If Colors match
                    if nodeSet.children[index].color == centerRing.color {
                        
                        
                        let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 0.2)
                        let scaleOut = SKAction.scaleTo(1.5, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)
                        let removeNode = SKAction.removeFromParent()
                        let fadeAndScale = SKAction.group([fadeOut,scaleOut])
                        let transitionRemove = SKAction.sequence([fadeAndScale,removeNode])
                        nodeSet.children[index].runAction(transitionRemove)
                        
                        scoreLabel.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration:NSTimeInterval(0.1)), SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))]))
                        
                        
                        
                        if nodeSet.children[index].name != "Scored" {
                            if !gameOver{
                                score = score + 1
                                (nodeSet.children[index] as SKNode).name = "Scored"
                                scoreLabel.text = String(score)
                                frenzyBonus = frenzyBonus + 1
                                updateHighScore()
                            }
                            
                        }
                    } else {
                        let turnBlack = SKAction.colorizeWithColor(SKColor.blackColor(), colorBlendFactor: 1.0, duration: 0.1)
                        let collapse = SKAction.scaleTo(0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0)
                        let removeNode = SKAction.removeFromParent()
                        let blackenOut = SKAction.sequence([turnBlack,collapse])
                        let collapseRemove = SKAction.sequence([blackenOut,removeNode])
                        scoreLabel.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration:NSTimeInterval(0.1)), SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))]))
                        nodeSet.children[index].runAction(collapseRemove)
                        
                        if nodeSet.children[index].name != "Deducted" {
                            if !gameOver{
                                if score > 0 {
                                    score = score - 1
                                    (nodeSet.children[index] as SKNode).name = "Deducted"
                                    scoreLabel.text = String(score)
                                    frenzyBonus = 0
                                    updateHighScore()
                                }
                            }
                        }
                    }
            }
        }
        
        // Frenzy Mode on
        for var index = 0; index < frenzySet.children.count; ++index{
            
            if ((frenzySet.children[index].position.x > centerRing.frame.minX)
                && (frenzySet.children[index].position.x < centerRing.frame.maxX)
                && (frenzySet.children[index].position.y > centerRing.frame.minY)
                && (frenzySet.children[index].position.y < centerRing.frame.maxY)) {
                    
                    // If Colors match
                    if frenzySet.children[index].color == centerRing.color {
                        
                        
                        let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 0.2)
                        let scaleOut = SKAction.scaleTo(1.5, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)
                        let removeNode = SKAction.removeFromParent()
                        let fadeAndScale = SKAction.group([fadeOut,scaleOut])
                        let transitionRemove = SKAction.sequence([fadeAndScale,removeNode])
                        frenzySet.children[index].runAction(transitionRemove)
                        
                        scoreLabel.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration:NSTimeInterval(0.1)), SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))]))
                        
                        
                        
                        if frenzySet.children[index].name != "Scored" {
                            if !gameOver{
                                score = score + 1
                                (frenzySet.children[index] as SKNode).name = "Scored"
                                scoreLabel.text = String(score)
                                updateHighScore()
                            }
                            
                        }
                    }
            }
        }
        
    }
    
    // Frenzy Mode
    func frenzyMode() {
        frenzyModeOn = true
        let spawn = SKAction.runBlock { () -> Void in
            self.setupNodes()
        }
        let delay = SKAction.waitForDuration(0.2)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        frenzySet.runAction(spawnThenDelayForever)
        let frenzyDelay = SKAction.waitForDuration(10)
        
        // End frenzy mode
        frenzySet.runAction(frenzyDelay, completion: {
            frenzyModeOn = false
            let delayBeforeDelete = SKAction.waitForDuration(5)
            let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 0.2)
            let scaleOut = SKAction.scaleTo(0, duration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)
            let removeNode = SKAction.removeFromParent()
            let fadeAndScale = SKAction.group([fadeOut,scaleOut])
            let transitionRemove = SKAction.sequence([delayBeforeDelete,fadeAndScale,removeNode])
            for var index = 0; index < frenzySet.children.count; ++index{
                (frenzySet.children[index] as SKNode).runAction(transitionRemove)
            }
            
            frenzySet.removeAllActions()
        })
    }
    
    
    
    // Function to handle object contact
    //    func didBeginContact(contact: SKPhysicsContact) {
    //        if ((contact.bodyA.contactTestBitMask & nodeCategory) == nodeCategory || ( contact.bodyB.contactTestBitMask & nodeCategory ) == nodeCategory){
    //            println("NodeImpact")
    //        }
    
    //    }
    
    
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self) as CGPoint
            var node: SKNode = self.nodeAtPoint(location)
            
            // Press Pause Button
            if (node.name == "pauseButton") {
                if (self.scene?.paused == false) {
                    self.scene?.paused = true
                } else {
                    self.scene?.paused = false
                }
                
                // Press Mono Button
            } else if (node.name == "monoModeIndicator") {
                if (monoModeIndicator.alpha == 1) {
                    monoModeIndicator.alpha = 0.1
                    for var index = 0; index < nodeSet.children.count; ++index{
                        (nodeSet.children[index] as SKSpriteNode).color = centerRing.color
                        
                    }
                    let fadeOut = SKAction.fadeAlphaTo(0.1, duration: 0.2)
                    let scaleIn = SKAction.scaleTo(1.0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0)
                    let fadeAndScale = SKAction.group([fadeOut,scaleIn])
                    monoModeIndicator.runAction(fadeAndScale)
                } else {
                    let fadeOut = SKAction.fadeAlphaTo(0.1, duration: 0.2)
                    let scaleIn = SKAction.scaleTo(1.0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0)
                    let fadeAndScale = SKAction.group([fadeOut,scaleIn])
                    monoModeIndicator.runAction(fadeAndScale)
                }
                
                // Tap A Mono Node
            } else if (node.name == "nodeM") {
                let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.2)
                let scaleIn = SKAction.scaleTo(1.5, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0)
                let fadeAndScale = SKAction.group([fadeIn,scaleIn])
                monoModeIndicator.runAction(fadeAndScale)
                node.removeFromParent()
                
                
                // Tap Clock Button
            } else if (node.name == "slowTimeIndicator") {
                if (slowTimeIndicator.alpha == 1) {
                    slowTimeIndicator.alpha = 0.1
                    timerLabel.fontSize = 30
                    clock.paused = true
                    timerLabel.fontColor = blueColor
                    let delay = SKAction.waitForDuration(10)
                    nodeSet.runAction(delay, completion: {
                        clock.paused = false
                        timerLabel.fontColor = UIColor.blackColor()
                        timerLabel.fontSize = 22
                        
                    })
                    
                    let fadeOut = SKAction.fadeAlphaTo(0.1, duration: 0.2)
                    let scaleIn = SKAction.scaleTo(1.0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0)
                    let fadeAndScale = SKAction.group([fadeOut,scaleIn])
                    slowTimeIndicator.runAction(fadeAndScale)
                } else {
                    let fadeOut = SKAction.fadeAlphaTo(0.1, duration: 0.2)
                    let scaleIn = SKAction.scaleTo(1.0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0)
                    let fadeAndScale = SKAction.group([fadeOut,scaleIn])
                    slowTimeIndicator.runAction(fadeAndScale)
                }
                
                // Tap A Clock Node
            } else if (node.name == "nodeT") {
                let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.2)
                let scaleIn = SKAction.scaleTo(1.5, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0)
                let fadeAndScale = SKAction.group([fadeIn,scaleIn])
                slowTimeIndicator.runAction(fadeAndScale)
                node.removeFromParent()
                
                // Tap any Node
            } else {
                if (self.scene?.paused == false) {
                    if ((node.name == "nodeR") || (node.name == "nodeB") || (node.name == "nodeG")) {
                        // Step 1
                        selectedNode = node as? SKSpriteNode;
                        // Stop the sprite
                        selectedNode?.physicsBody?.velocity = CGVectorMake(0,0)
                        // Step 2: save information about the touch
                        history = [TouchInfo(location:location, time:touch.timestamp)]
                    }
                }
                
                // Determine the new position for the invisible sprite:
                var xOffset:CGFloat = 1.0
                var yOffset:CGFloat = 1.0
                
                // Frenzy mode off
                for var index = 0; index < nodeSet.children.count; ++index{
                    if location.x>nodeSet.children[index].position.x {
                        xOffset = -1.0
                    }
                    if location.y>nodeSet.children[index].position.y {
                        yOffset = -1.0
                    }
                    
                    // Create an action to move the invisibleControllerSprite.
                    // This will cause automatic orientation changes for the hero sprite
                    let actionMoveInvisibleNode = SKAction.moveTo(CGPointMake(location.x - xOffset, location.y - yOffset), duration: 0.2)
                    invisibleControllerSprite.runAction(actionMoveInvisibleNode)
                    
                    // Create an action to move the hero sprite to the touch location
                    if (self.scene?.paused == false) {
                        let actionMove = SKAction.moveTo(location, duration: 1)
                        nodeSet.children[index].runAction(actionMove)
                        
                    }
                    selectedNode?.removeAllActions()
                }
                
                // Frenzy Mode on
                for var index = 0; index < frenzySet.children.count; ++index{
                    if location.x > frenzySet.children[index].position.x {
                        xOffset = -1.0
                    }
                    if location.y > frenzySet.children[index].position.y {
                        yOffset = -1.0
                    }
                    
                    // Create an action to move the invisibleControllerSprite.
                    // This will cause automatic orientation changes for the hero sprite
                    let actionMoveInvisibleNode = SKAction.moveTo(CGPointMake(location.x - xOffset, location.y - yOffset), duration: 0.2)
                    invisibleControllerSprite.runAction(actionMoveInvisibleNode)
                    
                    // Create an action to move the hero sprite to the touch location
                    if (self.scene?.paused == false) {
                        let actionMove = SKAction.moveTo(location, duration: 1)
                        frenzySet.children[index].runAction(actionMove)
                        selectedNode?.removeAllActions()
                    }
                    
                }
                if (node.name == "replayButton"){
                    
                    resetScene()
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self) as CGPoint
            
            var node: SKNode = self.nodeAtPoint(location)
            
            if (selectedNode != nil) {
                // Step 1. update sprite's position
                selectedNode?.position = location
                // Step 2. save touch data at index 0
                history?.insert(TouchInfo(location:location, time:touch.timestamp),atIndex:0)
            }
            var xOffset:CGFloat = 1.0
            var yOffset:CGFloat = 1.0
            
            // Frenzy mode off
            for var index = 0; index < nodeSet.children.count; ++index{
                if location.x>nodeSet.children[index].position.x {
                    xOffset = -1.0
                }
                if location.y>nodeSet.children[index].position.y {
                    yOffset = -1.0
                }
                
                // Create an action to move the invisibleControllerSprite.
                // This will cause automatic orientation changes for the hero sprite
                let actionMoveInvisibleNode = SKAction.moveTo(CGPointMake(location.x - xOffset, location.y - yOffset), duration: 0.2)
                invisibleControllerSprite.runAction(actionMoveInvisibleNode)
                
                // Create an action to move the hero sprite to the touch location
                if (self.scene?.paused == false){
                    let actionMove = SKAction.moveTo(location, duration: 1)
                    nodeSet.children[index].runAction(actionMove)
                    selectedNode?.removeAllActions()
                }
                
            }
            // Frenzy Mode on
            
            for var index = 0; index < frenzySet.children.count; ++index{
                if location.x > frenzySet.children[index].position.x {
                    xOffset = -1.0
                }
                if location.y > frenzySet.children[index].position.y {
                    yOffset = -1.0
                }
                
                // Create an action to move the invisibleControllerSprite.
                // This will cause automatic orientation changes for the hero sprite
                let actionMoveInvisibleNode = SKAction.moveTo(CGPointMake(location.x - xOffset, location.y - yOffset), duration: 0.2)
                invisibleControllerSprite.runAction(actionMoveInvisibleNode)
                
                // Create an action to move the hero sprite to the touch location
                if (self.scene?.paused == false) {
                    let actionMove = SKAction.moveTo(location, duration: 1)
                    frenzySet.children[index].runAction(actionMove)
                    selectedNode?.removeAllActions()
                    
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(self)
        if (selectedNode != nil && history!.count > 1) {
            var vx:CGFloat = 0.0
            var vy:CGFloat = 0.0
            var previousTouchInfo:TouchInfo?
            // Adjust this value as needed
            let maxIterations = 3
            var numElts:Int = min(history!.count, maxIterations)
            // Loop over touch history
            for index in 1...numElts{
                let touchInfo = history![index]
                let location = touchInfo.location
                if let previousLocation = previousTouchInfo?.location {
                    // Step 1
                    let dx = location.x - previousLocation.x
                    let dy = location.y - previousLocation.y
                    // Step 2
                    let dt = CGFloat(touchInfo.time - previousTouchInfo!.time)
                    // Step 3
                    vx += dx / dt
                    vy += dy / dt
                }
                previousTouchInfo = touchInfo
            }
            let count = CGFloat(numElts-1)
            // Step 4
            let velocity = CGVectorMake(vx/count,vy/count)
            selectedNode?.physicsBody?.velocity = velocity
            // Step 5
            selectedNode = nil
            history = nil
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if gameOver{
            self.removeAllActions()
        }
        if gameBegan{
            updateScore()
        }
        
        if frenzyBonus == 1 {
            frenzyBonus = 0
            frenzyMode()
        }
        
        
        
    }
}
