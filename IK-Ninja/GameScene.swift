/**
 Copyright (c) 2016 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import SpriteKit

class GameScene: SKScene {
  var shadow: SKNode!
  var lowerTorso: SKNode!
  var upperTorso: SKNode!
  
  var upperArmFront: SKNode!
  var lowerArmFront: SKNode!
  var fistFront: SKNode!
  
  var upperArmBack: SKNode!
  var lowerArmBack: SKNode!
  var fistBack: SKNode!
  
  let upperArmAngleDeg: CGFloat = -10
  let lowerArmAngleDeg: CGFloat = 130
  var rightPunch = true
  var firstTouch = false
  
  var head: SKNode!
  let targetNode = SKNode()
  var lastSpawnTimeInterval: NSTimeInterval = 0
  var lastUpdateTimeInterval: NSTimeInterval = 0
  
  override func didMoveToView(view: SKView) {
    // torso
    lowerTorso = childNodeWithName("torso_lower")
    upperTorso = lowerTorso.childNodeWithName("torso_upper")
    shadow  = childNodeWithName("shadow")
    lowerTorso.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - 30)
    shadow.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - 100)
    head = upperTorso.childNodeWithName("head")
    
    // front arm
    upperArmFront = upperTorso.childNodeWithName("arm_upper_front")
    lowerArmFront = upperArmFront.childNodeWithName("arm_lower_front")
    fistFront = lowerArmFront.childNodeWithName("fist_front")
    lowerArmFront.reachConstraints = SKReachConstraints(lowerAngleLimit: 0.0, upperAngleLimit: 160.0)
    
    // back arm
    upperArmBack = upperTorso.childNodeWithName("arm_upper_back")
    lowerArmBack = upperArmBack.childNodeWithName("arm_lower_back")
    fistBack = lowerArmBack.childNodeWithName("fist_back")
    lowerArmBack.reachConstraints = SKReachConstraints(lowerAngleLimit: 0.0, upperAngleLimit: 160.0)
    
    let orientToNodeConstraint = SKConstraint.orientToNode(targetNode, offset: SKRange(constantValue: 0.0))
    let range = SKRange(lowerLimit: CGFloat(-50).degreesToRadians(),
                        upperLimit: CGFloat(80).degreesToRadians())
    let rotationConstraint = SKConstraint.zRotation(range)
    rotationConstraint.enabled = false
    orientToNodeConstraint.enabled = false
    head.constraints = [orientToNodeConstraint, rotationConstraint]
  }
  
  
  // MARK: - Punching
  func tapForPunchAtLocation(location: CGPoint) {
    let punch = SKAction.reachTo(location, rootNode: upperArmFront, duration: 0.1)
    fistFront.runAction(punch)
  }
  
  func punchAtLocation(location: CGPoint, upperArmNode: SKNode, lowerArmNode: SKNode, fistNode: SKNode) {
    let punch = SKAction.reachTo(location, rootNode: upperArmNode, duration: 0.1)
    let restore = SKAction.runBlock {
      upperArmNode.runAction(SKAction.rotateToAngle(self.upperArmAngleDeg.degreesToRadians(), duration: 0.1))
      lowerArmNode.runAction(SKAction.rotateToAngle(self.lowerArmAngleDeg.degreesToRadians(), duration: 0.1))
    }
    
    let checkIntersection = intersectionCheckActionForNode(fistNode)
    fistNode.runAction(SKAction.sequence([punch, checkIntersection, restore]))
  }
  
  func punchAtLocation(location: CGPoint) {
    if rightPunch {
      punchAtLocation(location, upperArmNode: upperArmFront, lowerArmNode: lowerArmFront, fistNode: fistFront)
    }
    else {
      punchAtLocation(location, upperArmNode: upperArmBack, lowerArmNode: lowerArmBack, fistNode: fistBack)
    }
    rightPunch = !rightPunch
  }
  
  
  // MARK: - Shuriken
  func addShuriken() {
    let shuriken = SKSpriteNode(imageNamed: "projectile")
    
    let minY = lowerTorso.position.y - 60 + shuriken.size.height/2
    let maxY = lowerTorso.position.y  + 140 - shuriken.size.height/2
    let rangeY = maxY - minY
    let actualY = (CGFloat(arc4random()) % rangeY) + minY
    
    let left = arc4random() % 2
    let actualX = (left == 0) ? -shuriken.size.width/2 : size.width + shuriken.size.width/2
    
    shuriken.position = CGPointMake(actualX, actualY)
    shuriken.name = "shuriken"
    shuriken.zPosition = 1
    addChild(shuriken)
    
    let minDuration = 4.0
    let maxDuration = 6.0
    let rangeDuration = maxDuration - minDuration
    let actualDuration = (Double(arc4random()) % rangeDuration) + minDuration
    
    let actionMove = SKAction.moveTo(CGPointMake(size.width/2, actualY), duration: actualDuration)
    let actionMoveDone = SKAction.removeFromParent()
    shuriken.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    
    let angle = left == 0 ? CGFloat(-90).degreesToRadians() : CGFloat(90).degreesToRadians()
    let rotate = SKAction.repeatActionForever(SKAction.rotateByAngle(angle, duration: 0.2))
    shuriken.runAction(SKAction.repeatActionForever(rotate))
  }
  
  
  // MARK: - Projectile Timing
  func updateWithTimeSinceLastUpdate(timeSinceLast: CFTimeInterval) {
    lastSpawnTimeInterval = timeSinceLast + lastSpawnTimeInterval
    if lastSpawnTimeInterval > 0.75 {
      lastSpawnTimeInterval = 0
      addShuriken()
    }
  }
  
  override func update(currentTime: CFTimeInterval) {
    var timeSinceLast = currentTime - lastUpdateTimeInterval
    lastUpdateTimeInterval = currentTime
    if timeSinceLast > 1.0 {
      timeSinceLast = 1.0 / 60.0
      lastUpdateTimeInterval = currentTime
    }
    updateWithTimeSinceLastUpdate(timeSinceLast)
  }
  
  
  // MARK: - Hit Detection
  func intersectionCheckActionForNode(effectorNode: SKNode) -> SKAction {
    let checkIntersection = SKAction.runBlock {
      
      for object: AnyObject in self.children {
        // check for intersection against any sprites named "shuriken"
        if let node = object as? SKSpriteNode {
          if node.name == "shuriken" {
            // convert coordinates into common system based on root node
            let effectorInNode = self.convertPoint(effectorNode.position, fromNode:effectorNode.parent!)
            var shurikenFrame = node.frame
            shurikenFrame.origin = self.convertPoint(shurikenFrame.origin, fromNode: node.parent!)
            
            if shurikenFrame.contains(effectorInNode) {
              // play a hit sound
              self.runAction(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))
              
              // show a spark effect
              let spark = SKSpriteNode(imageNamed: "spark")
              spark.position = node.position
              spark.zPosition = 60
              self.addChild(spark)
              let fadeAndScaleAction = SKAction.group([
                SKAction.fadeOutWithDuration(0.2),
                SKAction.scaleTo(0.1, duration: 0.2)])
              let cleanUpAction = SKAction.removeFromParent()
              spark.runAction(SKAction.sequence([fadeAndScaleAction, cleanUpAction]))
              
              // remove the shuriken
              node.removeFromParent()
            }
            else {
              // play a miss sound
              self.runAction(SKAction.playSoundFileNamed("miss.mp3", waitForCompletion: false))
            }
          }
        }
      }
    }
    return checkIntersection
  }
  
  
  // MARK: - Touches Override
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if !firstTouch {
      for c in head.constraints! {
        let constraint = c
        constraint.enabled = true
      }
      firstTouch = true
    }
    
    for touch: AnyObject in touches {
      let location = touch.locationInNode(self)
      lowerTorso.xScale =
        location.x < CGRectGetMidX(frame) ? abs(lowerTorso.xScale) * -1 : abs(lowerTorso.xScale)
      punchAtLocation(location)
      targetNode.position = location
    }
  }
}
