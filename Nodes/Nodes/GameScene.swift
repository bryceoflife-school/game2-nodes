//
//  GameScene.swift
//  Nodes
//
//  Created by Bryce Daniel on 12/6/14.
//  Copyright (c) 2014 Bryce Daniel. All rights reserved.
//

/* Todo:
    * TimeBonus
    * Powerups
    * Pause Button
    * Restart Button


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

// Colors
let redColor = SKColor(red: 1, green: 28/255, blue: 105/255, alpha: 1)
let greenColor = SKColor(red: 166/255, green: 232/255, blue: 99/255, alpha: 1)
let blueColor = SKColor(red: 62/225, green: 197/255, blue: 255/255, alpha: 1)

// GameStates
var score: Int!
var highScore = NSInteger()
var timeBonus: Int!
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
        setupTimeLabel()
        setupCenterRing()
        spawnNodes()
        
        //        setupColorBar()
        
        nodeSet = SKNode()
        self.addChild(nodeSet)
        randomlyChangeRingColor()
        
        timeBonus = 0
        
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
        scoreLabel.position = CGPointMake(self.frame.width / 25, self.frame.height / 1.05)
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
        highScoreLabel.position = CGPointMake(self.frame.width / 25, self.frame.height / 1.1)
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
        self.addChild(timerLabel)
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
            self.runAction(decrimentThenDelayForTimer, completion: {
                // Call game over function
                gameOver = true
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
            nodeSet.addChild(nodeBall)
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
            nodeSet.addChild(nodeBall)
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
            nodeSet.addChild(nodeBall)
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
    
    func updateScore() {
        
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
                                timeBonus = timeBonus + 1
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
                                    timeBonus = 0
                                    updateHighScore()
                                }
                            }
                        }
                    }
            }
        }
    }
    
    
    
    // Function to handle object contact
    //    func didBeginContact(contact: SKPhysicsContact) {
    //        if ((contact.bodyA.contactTestBitMask & nodeCategory) == nodeCategory || ( contact.bodyB.contactTestBitMask & nodeCategory ) == nodeCategory){
    //            println("NodeImpact")
    //        }
    //
    //    }
    
    
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self) as CGPoint
            var node: SKNode = self.nodeAtPoint(location)
            
            if ((node.name == "nodeR") || (node.name == "nodeB") || (node.name == "nodeG")) {
                // Step 1
                selectedNode = node as? SKSpriteNode;
                // Stop the sprite
                selectedNode?.physicsBody?.velocity = CGVectorMake(0,0)
                // Step 2: save information about the touch
                history = [TouchInfo(location:location, time:touch.timestamp)]
            }
            
            // Determine the new position for the invisible sprite:
            var xOffset:CGFloat = 1.0
            var yOffset:CGFloat = 1.0
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
                let actionMove = SKAction.moveTo(location, duration: 1)
                nodeSet.children[index].runAction(actionMove)
                selectedNode?.removeAllActions()
                
                
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
                let actionMove = SKAction.moveTo(location, duration: 1)
                nodeSet.children[index].runAction(actionMove)
                selectedNode?.removeAllActions()
                
                
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
            for index in 1...numElts {
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
        
        
        
        
    }
}
