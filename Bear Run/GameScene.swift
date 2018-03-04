//
//  GameScene.swift
//  Bear Run
//
//  Created by Hieu Nguyen on 10/5/17.
//  Copyright © 2017 HM Dev. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation


class GameScene: SKScene {
    //====================================================================================
    //didMove is similar to viewDidLoad() from UIKIT
    override func didMove(to view: SKView) {
        
        //-BACKGROUND-
        //Editing my background in code by typecasting a SpriteNode to SKSPriteNode since .childNode() returns
        //a SpriteNode.  Changing background scale to 0.5x and 0.5y to fit the screen for Iphone 6
        let startingBackground:SKSpriteNode = self.childNode(withName: "Start_Background") as! SKSpriteNode
        startingBackground.xScale = 0.5
        startingBackground.yScale = 0.5
        
        //Background music
        let bg:SKAudioNode = SKAudioNode(fileNamed: "tropics.mp3")
        bg.autoplayLooped = true
        self.addChild(bg)
        
        //-Starting player- created in code.  Notice difference from loading from .sks scene and loading from
        //assets in code!
        let player:SKSpriteNode = SKSpriteNode(imageNamed: "Idle_bear_A")
        player.position = CGPoint(x: -70.808, y: -87.015)
        player.xScale = 0.4
        player.yScale = 0.4
        self.addChild(player)
        
    }
    
    //Changes to GamePlay scene
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let view = self.view{
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GamePlay") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
            }
        }
    }
}
