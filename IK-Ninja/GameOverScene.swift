//
//  GameOverScene.swift
//  IK-Ninja
//
//  Created by Louis Tur on 7/8/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
  override func didMoveToView(view: SKView) {
    
    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
    myLabel.text = "Game Over"
    myLabel.fontSize = 65
    myLabel.position = CGPoint(x:CGRectGetMidX(frame), y:CGRectGetMidY(frame))
    addChild(myLabel)
    
    runAction(SKAction.sequence([
      SKAction.waitForDuration(1.0),
      SKAction.runBlock({
        let transition = SKTransition.fadeWithDuration(1.0)
        let scene = GameScene(fileNamed:"GameScene")
        scene!.scaleMode = .AspectFill
        scene!.size = self.size
        self.view?.presentScene(scene!, transition: transition)
      })]))
  }
}
