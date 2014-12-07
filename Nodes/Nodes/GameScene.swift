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

// GameStates
var score: Int!
var haveMPowerup: Bool!
var haveTPowerup: Bool!
//var colorBarProgress: Int!
//var timer

// Textures
var nodeTexture: SKTexture!

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
//        setupTimeLabel()
//        setupCenterRing()
//        setupColorBar()

        
    }
    
    // Add Background
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
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


    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
