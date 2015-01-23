//
//  PlayScene.swift
//  jumpball
//
//  Created by wangbo on 1/16/15.
//  Copyright (c) 2015 wangbo. All rights reserved.
//

import SpriteKit

class PlayScene: SKScene, SKPhysicsContactDelegate{
    
    let runningBar = SKSpriteNode(imageNamed: "bar")
    let hero = SKSpriteNode(imageNamed: "hero")
    let block1 = SKSpriteNode(imageNamed: "block1")
    let block2 = SKSpriteNode(imageNamed: "block2")
    var heroBaseline = CGFloat(0)
    var origRunningBarPositionX = CGFloat(0)
    var maxBarX = CGFloat(0)
    var groundspeed = 10
    var velocityY = CGFloat(0)
    var onGround = true
    let gravity = CGFloat(0.6)
    var blockMaxX = CGFloat(0)
    var origBlockPositionX = CGFloat(0)
    var score = 0
    var scoreText = SKLabelNode(fontNamed: "Chaclkduster")
    
    enum ColliderType:UInt32{
        case Hero = 1
        case Block = 2
    }
    override func  didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor(hex: 0x80D9FF)
        
        //delegate the physics world to here
        self.physicsWorld.contactDelegate = self
        
        // running bar is the ground, set anchor point to be middle y
        self.runningBar.anchorPoint = CGPointMake(0, 0.5)
        self.runningBar.position = CGPointMake(CGRectGetMinX(self.frame),CGRectGetMinY(self.frame) + (self.runningBar.size.height / 2))
        //intialize the bar's original position
         self.origRunningBarPositionX = self.runningBar.position.x
        // the longest distance running bar can slide
         self.maxBarX = self.runningBar.size.width - self.frame.size.width
        // the bar move towards left, therefore all the position is negative
         self.maxBarX *= -1;
        
        //hero position and set physics body to make it collide
         self.heroBaseline = self.runningBar.position.y + (self.runningBar.size.height / 2) + (self.hero.size.height / 2)
        self.hero.position = CGPointMake(CGRectGetMinX(self.frame) + (self.hero.size.width / 4) + self.hero.size.width
 , self.heroBaseline)
        // set the physics body to hero
        self.hero.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(self.hero.size.width / 2))
        self.hero.physicsBody?.affectedByGravity = false
        // distinguish the enemy and friend
        self.hero.physicsBody?.categoryBitMask = ColliderType.Hero.rawValue
        self.hero.physicsBody?.contactTestBitMask = ColliderType.Block.rawValue
        self.hero.physicsBody?.collisionBitMask = ColliderType.Block.rawValue
        
        //set two blocks original position which is beyong the right screen
        self.block1.position = CGPointMake(CGRectGetMaxX(self.frame) + self.block1.size.width, self.heroBaseline)
        self.block2.position = CGPointMake(CGRectGetMaxX(self.frame) + self.block2.size.width, self.heroBaseline + ( self.block2.size.height - self.block1.size.height) / 2 )
        self.block1.name = "block1"
        self.block2.name = "block2"
        self.block1.physicsBody = SKPhysicsBody(rectangleOfSize: self.block1.size)
        // will not be pushed, static; same type will not be overlapped
        self.block1.physicsBody?.dynamic = false
        self.block1.physicsBody?.categoryBitMask = ColliderType.Block.rawValue
        self.block1.physicsBody?.contactTestBitMask = ColliderType.Hero.rawValue
        self.block1.physicsBody?.collisionBitMask = ColliderType.Hero.rawValue
        self.block2.physicsBody = SKPhysicsBody(rectangleOfSize: self.block1.size)
        // will not be pushed, static
        self.block2.physicsBody?.dynamic = false
        self.block2.physicsBody?.categoryBitMask = ColliderType.Block.rawValue
        self.block2.physicsBody?.contactTestBitMask = ColliderType.Hero.rawValue
        self.block2.physicsBody?.collisionBitMask = ColliderType.Hero.rawValue
        
        //build the dictioanry
        blockStatues["block1"] = BlockStatus(isRunning: false, timeGapForNextRun: random(), currentInterval: UInt32(0))
        blockStatues["block2"] = BlockStatus(isRunning: false, timeGapForNextRun: random(), currentInterval: UInt32(0))
        self.blockMaxX = 0 - self.block1.size.width / 2
        self.origBlockPositionX = self.block1.position.x
        
        // build score
        self.scoreText.text = "0"
        self.scoreText.fontSize = 42
        self.scoreText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
         self.addChild(runningBar)
         self.addChild(hero)
         self.addChild(block1)
         self.addChild(block2)
         self.addChild(scoreText)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // reconstruct the view
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene{
            let skView = self.view as SKView!
            skView.ignoresSiblingOrder = true
            scene.size = skView.bounds.size
            scene.scaleMode = .AspectFill
            skView?.presentScene(scene)
        }
    }
    
    func random() -> UInt32{
        var range = UInt32(50)...UInt32(100)
        return range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1)
    }
    
    //build a new dictionary to record blocks information
    var blockStatues:Dictionary<String, BlockStatus> = [:]
    
    // let hero jump, when it start to touch, it begin to jump
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if self.onGround{
            // add power only once
            self.velocityY = -36.0
            self.onGround = false
        }
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // adjust the strength, tap shortly still in high speed let it drop quick, tap longer in low speed maintain it
        if self.velocityY < -9 {
            self.velocityY = -9.0
        }
        
    }
    
    func blockrunner(){
        for(block, blockStatus) in self.blockStatues{
            var thisBlock = self.childNodeWithName(block)
            if blockStatus.shouldRunBlock(){
                // reset up the appear time
                blockStatus.timeGapForNextRun = random()
                blockStatus.currentInterval = 0
                blockStatus.isRunning = true
            }
            if blockStatus.isRunning{
                    // move left
                if thisBlock?.position.x > blockMaxX{
                    thisBlock?.position.x -= CGFloat(self.groundspeed)
                }else{
                    // if it move beyond bound
                    thisBlock?.position.x = self.origBlockPositionX
                    blockStatus.isRunning = false
                    self.score++
                    if(self.score % 5 == 0){
                        self.groundspeed++
                    }
                    self.scoreText.text = String(self.score)
                }
            }else{
                blockStatus.currentInterval++
            }
        }
    }
    override func update(currentTime: NSTimeInterval) {
        // when the bar have not over
        if self.runningBar.position.x <= maxBarX{
            //set the bar back to original position
            self.runningBar.position.x = self.origRunningBarPositionX
        }
        
        // rotate the hero
        var degreeRotation = CDouble(self.groundspeed) * M_PI / 180
        self.hero.zRotation -= CGFloat(degreeRotation)
        
        // move the bar
        runningBar.position.x -= CGFloat(self.groundspeed)
        
        //the gravity
        self.velocityY += self.gravity
        self.hero.position.y -= velocityY
        if self.hero.position.y < self.heroBaseline{
            self.hero.position.y = self.heroBaseline
            velocityY = 0.0
            self.onGround = true
        }
        
        blockrunner()
    }
}
