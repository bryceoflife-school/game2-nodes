//
//  GameScene.swift
//  Nodes
//
//  Created by Bryce Daniel on 12/6/14.
//  Copyright (c) 2014 Bryce Daniel. All rights reserved.
//

import SpriteKit
import UIKit
import Foundation

// Object Variables
var background: SKSpriteNode!
var timerLabel: SKLabelNode!
var scoreLabel: SKLabelNode!
var centerRing: SKSpriteNode!
var node: SKSpriteNode!
var colorBar: SKSpriteNode!
var nodeSet: SKNode!
var nodeColor: Int!

// Colors
let redColor = SKColor(red: 1, green: 28/255, blue: 105/255, alpha: 1)
let greenColor = SKColor(red: 166/255, green: 232/255, blue: 99/255, alpha: 1)
let blueColor = SKColor(red: 62/225, green: 197/255, blue: 255/255, alpha: 1)

// GameStates
var score: Int!
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
        setupTimeLabel()
        setupCenterRing()
        spawnNodes()
        
        //        setupColorBar()
        
        nodeSet = SKNode()
        self.addChild(nodeSet)
       
        
        
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
        scoreLabel.position = CGPointMake(self.frame.width / 30, self.frame.height / 1.05)
        scoreLabel.text = String(score)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
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
        centerRing.color = greenColor
        centerRing.colorBlendFactor = 1.0
        self.addChild(centerRing)
    }
    
    func setupNodes(){
        
        node = SKSpriteNode(imageNamed: "nodeW")
        
        do {
            columnMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(columnMultiplier <= 0.1 || columnMultiplier >= 0.95)
        
        do {
            rowMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(rowMultiplier <= 0.1 || rowMultiplier >= 0.95)
        
        do {
            sizeMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(sizeMultiplier <= 0.5 || sizeMultiplier >= 1.0)
        
        node.size = CGSizeMake(sizeMultiplier * node.frame.width / 2, sizeMultiplier *  node.frame.height / 2)
        
        node.position = CGPointMake((columnMultiplier * self.frame.width), (rowMultiplier * self.frame.size.height))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.frame.height/2)
        node.physicsBody?.categoryBitMask = nodeCategory
        node.physicsBody?.contactTestBitMask = nodeCategory
        node.physicsBody?.dynamic = true
        node.physicsBody?.affectedByGravity = false
        node.colorBlendFactor = 1
        
       
        nodeColor = Int(arc4random_uniform(3))
        switch nodeColor {
        case 0:
            node.color = redColor
            node.name = "nodeR"
            nodeSet.addChild(node)
        case 1:
            node.color = blueColor
            node.name = "nodeB"
            nodeSet.addChild(node)
        case 2:
            node.color = greenColor
            node.name = "nodeG"
            nodeSet.addChild(node)
        default:
            break
        }
        
        
        node.alpha = 0
        let scale0 = SKAction.scaleTo(0, duration: 0)
        node.runAction(scale0)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.2)
        let scaleIn = SKAction.scaleTo(1.0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0)
        let fadeAndScale = SKAction.group([fadeIn,scaleIn])
        node.runAction(fadeAndScale)
        
        
    }
    
    
    func spawnNodes(){
            let spawn = SKAction.runBlock { () -> Void in
                self.setupNodes()
                 gameBegan = true
            }
            
            let delay = SKAction.waitForDuration(2.0)
            let spawnThenDelay = SKAction.sequence([spawn, delay])
            let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
            self.runAction(spawnThenDelayForever)
    }
    
    func updateScore() {
        
        for var index = 0; index < nodeSet.children.count; ++index{
            
            if ((nodeSet.children[index].position.x > centerRing.frame.minX)
                && (nodeSet.children[index].position.x < centerRing.frame.maxX)
                && (nodeSet.children[index].position.y > centerRing.frame.minY)
                && (nodeSet.children[index].position.y < centerRing.frame.maxY)) {
                    
                    // If Colors match
                    if nodeSet.children[index].color == centerRing.color {
                        println("Goodbye")
                        nodeSet.children[index].removeFromParent()
                        score = score + 1
                        scoreLabel.text = String(score)
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
