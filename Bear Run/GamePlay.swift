//
//  GamePlay.swift
//  Bear Run
//
//  Created by Hieu Nguyen on 10/5/17.
//  Copyright © 2017 HM Dev. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation


class GamePlay: SKScene, SKPhysicsContactDelegate {
    
    
    //Player spritenode
    var player1 = SKSpriteNode()
    
    //Floor spritenode
    var surface_floor = SKSpriteNode()
    
    //Label spritenode
    var score_label = SKLabelNode()
    var life_label = SKLabelNode()
    
    //Our texture arrays
    var runningRightTextureArray = [SKTexture]()
    var runningLeftTextureArray = [SKTexture]()
    var idleTextureArray = [SKTexture]()
    let redball_texture = SKTexture(imageNamed: "red ball")
    
    //Our player position
    let player_xPosition = 0.0
    let player_yPosition = -107.0
    let ball_yPosition = 230
    
    //Determines left or right
    var isRight : Bool = false
    var isLeft : Bool = false
    var isMoving: Bool = false
    
    //Bitmask Collisions
    let noCategory:UInt32 = 0
    let playerCategory:UInt32 = 0b1             // 1
    let itemCategory:UInt32 = 0b1 << 1          // 2
    let floorCategory:UInt32 = 0b1 << 2         // 4

    //Counters
    var score = 0
    var life = 3
    var rate = 5.0
    
    //START OUR GAME
    override func didMove(to view: SKView) {
        //Detect collisions
        self.physicsWorld.contactDelegate = self
        
        //Start game
        initGame()
        
        //Idle texture array action
        player1.run(SKAction.repeatForever(SKAction.animate(with: idleTextureArray, timePerFrame: 0.2)))
        
    }
    
    //Function that init our game
    private func initGame(){
        
        //Initialize our objects
        initObjects()
        initMovementAnimation()
        spawn_timer()
        
        //Background music
        let bg:SKAudioNode = SKAudioNode(fileNamed: "tropics.mp3")
        bg.autoplayLooped = true
        self.addChild(bg)
    }
    
    //Handles our Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        //Category bit masks
        let cA:UInt32 = contact.bodyA.categoryBitMask
        let cB:UInt32 = contact.bodyB.categoryBitMask
        
        if cA == playerCategory || cB == playerCategory{
            if contact.bodyB.node != nil{
                
                let otherNode:SKNode = contact.bodyB.node!
                playerDidCollide(with: otherNode)
            }
        }
            //Ball and floor collided
        else{
            contact.bodyB.node?.removeFromParent()
            print("ball and floor collided.")
            life -= 1
        }
    }
    
    //Checks if other node is player, ball, or wall
    func playerDidCollide(with other:SKNode){
        let otherCategory = other.physicsBody?.categoryBitMask
        
        //Ball and player collided
        if otherCategory == itemCategory {
            
            //When dog gets a ball, play emitter
            let dog_got:SKEmitterNode = SKEmitterNode(fileNamed: "chomp")!
            dog_got.position = other.position
            self.addChild(dog_got)
            dog_got.removeFromParent()
            
            other.removeFromParent()
            print("ball and player collided")
            score += 1
        }
    }
    
    //Creating Objects
    private func initObjects(){
        //Creating player object [scaling and position]
        player1 = self.childNode(withName: "player_1") as! SKSpriteNode
        //Player Bitmask
        player1.physicsBody?.categoryBitMask = playerCategory
        player1.physicsBody?.contactTestBitMask = itemCategory
        //Position
        player1.position = CGPoint(x: player_xPosition, y: player_yPosition)
        
        //Creating surface floor
        surface_floor = self.childNode(withName: "game_floor") as! SKSpriteNode
        
        //Floor BitMask
        surface_floor.physicsBody?.categoryBitMask = floorCategory
        surface_floor.physicsBody?.contactTestBitMask = itemCategory
        
        //Spawn balls
        spawn_red()
        spawn_blue()
        spawn_yellow()
        
        //Labels
        score_label = self.childNode(withName: "Score") as! SKLabelNode
        score_label.position = CGPoint(x: -250, y: 148)
        life_label = self.childNode(withName: "Life") as! SKLabelNode
        life_label.position = CGPoint(x: 247, y: 146)
        
    }
    
    private func initMovementAnimation(){
        //Movement Animation Texture
        for i in 1...3{
            let textureImage = "dog_running_right_\(i)"
            runningRightTextureArray.append(SKTexture(imageNamed: textureImage))
        }
        
        for i in 1...3{
            let textureImage = "dog_running_left_\(i)"
            runningLeftTextureArray.append(SKTexture(imageNamed: textureImage))
        }
        
        for i in 1...3{
            let textureImage = "idle_dog_\(i)"
            idleTextureArray.append(SKTexture(imageNamed: textureImage))
        }
    }
    
    func random_x() -> Int{
        let lower = -300
        let upper = 300
        let result = Int(arc4random_uniform(UInt32(upper - lower + 1))) +   lower

        return result
    }
    
    //If touch on screen, the player should increment x - position. 
    //Because of bottom_layer physics set 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Determines if touch is left or right
        for touch in (touches) {
            let location = touch.location(in: self)
            
            //Determine touch direction
            if(location.x < 0){
                isLeft = true
                isRight = false
                isMoving = true
            }
            
            if(location.x > 0){
                isRight = true
                isLeft = false
                isMoving = true

            }
        }
        
        //If left touch then move xPosition by -40
        if(isLeft && isMoving){
            player1.run(SKAction.repeatForever(SKAction.animate(with: runningLeftTextureArray, timePerFrame: 0.2)))
            player1.run(SKAction.repeatForever(SKAction.moveBy(x: -40, y: 0, duration: 0.2)))

        }
        //If right touch then move xPosition by 40
        if(isRight && isMoving){
            player1.run(SKAction.repeatForever(SKAction.animate(with: runningRightTextureArray, timePerFrame: 0.2)))
            player1.run(SKAction.repeatForever(SKAction.moveBy(x: 40, y: 0, duration: 0.2)))
        }
    }
    
    //When touches end, motion SHOULD stop...but its not oh my god.. HEADACHE
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isLeft = false
        isRight = false
        isMoving = false
    }
    
    //Function to move the dog using SKAction to move in increments
    func moveDog (moveBy: CGFloat, who: SKSpriteNode) {
        let moveAction = SKAction.moveBy(x: moveBy, y: 0, duration: 0.3)  //only change x value, so set y = 0
        let repeatForEver = SKAction.repeatForever(moveAction)      //use SKACTION
        let seq = SKAction.sequence([moveAction, repeatForEver])

        //running our action
        who.run(seq)
    }
    
    
    func spawn_red(){
        let random_x_postion = random_x()
        
        //Creating redball object [scaling and position]
        let redball1:SKSpriteNode = SKSpriteNode(imageNamed: "red ball")
        redball1.position = CGPoint(x: random_x_postion, y: ball_yPosition + 15)

        self.addChild(redball1)

        //Physics
        redball1.physicsBody = SKPhysicsBody(texture: redball_texture, size: redball_texture.size())
        redball1.physicsBody?.isDynamic = true
        redball1.physicsBody?.allowsRotation = true
        redball1.physicsBody?.affectedByGravity = true
        redball1.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        redball1.physicsBody?.mass = 0.349065899848938;
        
        //Item Bitmask
        redball1.physicsBody?.categoryBitMask = itemCategory
        redball1.physicsBody?.contactTestBitMask = playerCategory | floorCategory
    }
    
    func spawn_yellow(){
        let random_x_postion = random_x()
        
        //Creating yellowball object [scaling and position]
        let yellowball1:SKSpriteNode = SKSpriteNode(imageNamed: "yellow ball")
        yellowball1.position = CGPoint(x: random_x_postion, y: ball_yPosition + 30)
        self.addChild(yellowball1)

        //Physics         
        yellowball1.physicsBody = SKPhysicsBody(circleOfRadius: max(yellowball1.size.width / 2,
                                                                    yellowball1.size.height / 2))
        yellowball1.physicsBody?.isDynamic = true
        yellowball1.physicsBody?.allowsRotation = true
        yellowball1.physicsBody?.affectedByGravity = true
        yellowball1.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        yellowball1.physicsBody?.mass = 0.349065899848938;

        //Item Bitmask
        yellowball1.physicsBody?.categoryBitMask = itemCategory
        yellowball1.physicsBody?.contactTestBitMask = playerCategory | floorCategory
    }
    
    func spawn_blue(){
        let random_x_postion = random_x()
        
        //Creating blueball object [scaling and position]
        let blueball1:SKSpriteNode = SKSpriteNode(imageNamed: "blueball")
        blueball1.position = CGPoint(x: random_x_postion, y: ball_yPosition + 45)

        self.addChild(blueball1)

        //Physics         
        blueball1.physicsBody = SKPhysicsBody(circleOfRadius: max(blueball1.size.width / 2,
                                                                  blueball1.size.height / 2))
        blueball1.physicsBody?.isDynamic = true
        blueball1.physicsBody?.allowsRotation = true
        blueball1.physicsBody?.affectedByGravity = true
        blueball1.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        blueball1.physicsBody?.mass = 0.349065899848938;

        //Item Bitmask
        blueball1.physicsBody?.categoryBitMask = itemCategory
        blueball1.physicsBody?.contactTestBitMask = playerCategory | floorCategory
    }
    
    //Function to spawn more balls
    func spawnBalls(){
        let randomNum = Int(arc4random_uniform(2) + 1 )
        
        if randomNum == 1{
            spawn_red()
        }
        if randomNum == 2{
            spawn_blue()
        }
        if randomNum == 3{
            spawn_yellow()
        }
    }
    
    // our rate
    func calc_timer(how_Fast: Double){
        rate = 1.0
        print("\(rate) is new rate")
    }
    
    // timer for spawning object
    func spawn_timer() {
        let wait  = SKAction.wait(forDuration: 2, withRange: 5)
        let spawn   = SKAction.run { self.spawnBalls() }
        
        let action = SKAction.sequence([wait, spawn])
        
        // If you don't want this action to run forever, then remove this action!
        let forever = SKAction.repeatForever(action)
        
        self.run(forever)
    }
    
    // update our game
    override func update(_ currentTime: CFTimeInterval) {
        score_label.text = ("Score: \(score)")
        life_label.text = ("Life: \(life)")
        
        //Return to main menu if all life is gone
        if life <= 0 {
            if let view = self.view{
                // Load the SKScene from 'GameScene.sks'
                if let scene = SKScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
                }
            }
        }
    }
}



































