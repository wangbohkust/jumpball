//
//  GameScene.swift
//  jumpball
//
//  Created by wangbo on 1/16/15.
//  Copyright (c) 2015 wangbo. All rights reserved.
//

import SpriteKit

// the scene of game preparation
class GameScene: SKScene {
    
    // everything on the scene is spritenode
    let playButton = SKSpriteNode(imageNamed: "play")
    
    // called when one scene move to view and start
    override func didMoveToView(view: SKView) {
        // set button position to be center of frame by using CGPoint
        self.playButton.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        self.addChild(playButton)
        self.backgroundColor = UIColor(hex: 0x80D9FF)
    }
    
    // called when someone touch the screen
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        for touch: AnyObject in touches {
            // touch the node which stands for scene
            let location = touch.locationInNode(self)
            // check the object on corresponding location
            if self.nodeAtPoint(location) == self.playButton{
                // construct a new scene and grab current view
                var scene = PlayScene(size: self.size)
                let skView = self.view as SKView!
                skView?.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                // current view present new scene
                skView.presentScene(scene)
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
