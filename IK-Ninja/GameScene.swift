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
  
  override func didMoveToView(view: SKView) {
    // torso
    lowerTorso = childNodeWithName("torso_lower")
    upperTorso = lowerTorso.childNodeWithName("torso_upper")
    shadow  = childNodeWithName("shadow")
    lowerTorso.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - 30)
    shadow.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - 100)
    
    // front arm
    upperArmFront = upperTorso.childNodeWithName("arm_upper_front")
    lowerArmFront = upperArmFront.childNodeWithName("arm_lower_front")
    fistFront = lowerArmFront.childNodeWithName("fist_front")
    lowerArmFront.reachConstraints = SKReachConstraints(lowerAngleLimit: 0.0, upperAngleLimit: 160.0)
    
    // back arm
    upperArmBack = upperTorso.childNodeWithName("arm_upper_back")
    lowerArmBack = upperArmBack.childNodeWithName("arm_lower_back")
    lowerArmBack.reachConstraints = SKReachConstraints(lowerAngleLimit: 0.0, upperAngleLimit: 160.0)
  }
  
  func punchAtLocation(location: CGPoint) {
    let punch = SKAction.reachTo(location, rootNode: upperArmFront, duration: 0.1)
    fistFront.runAction(punch)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch: AnyObject in touches {
      let location = touch.locationInNode(self)
      punchAtLocation(location)
    }
  }
}
