//
//  MainScene
//  DatingApp
//
//  Created by Abhijeet Malamkar on 2/28/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import SpriteKit
import GameplayKit
import Firebase

class MainScene: SKScene , SKPhysicsContactDelegate{
    
    var nodes:[SKSpriteNode] = []
    var nodeCategories:[UInt32] = []
    var viewController:MainScene?
    var transitionDelegate:ProfileTransition?
    let gravityCategory: UInt32 = 0x1 << 30
    let springFieldCategory: UInt32 = 0x1 << 31
    let emptyFieldCategory: UInt32 = 0x1 << 29
    var minimumSize:Int?
    let dt: CGFloat = 1.0/60.0 //Delta time.
    let radiusLowerBound: CGFloat = 1.0 //Minimum radius between nodes check.
    let strength: CGFloat = 10000 //Make gravity less weak and more fun!
    
    var midPoint:CGPoint?
    
    var users = [User]()
    let gravity = SKFieldNode.radialGravityField()
    var selectionGravity = SKFieldNode.linearGravityField(withVector: vector3(vector2(0, 0), 0))
    
    override func didMove(to view: SKView) {
        minimumSize = Int((midPoint?.x)!) / 2
        let border = CGRect(x: 0, y: 0, width: (midPoint?.x)!*2, height: (midPoint?.y)!*2)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: border)
        
        self.physicsWorld.gravity = CGVector()
        fetchUser()
        
        
        selectionGravity.categoryBitMask = emptyFieldCategory
        
        gravity.strength = 0.1
        gravity.position = CGPoint(x: (midPoint?.x)! - 100, y: (midPoint?.y)! - 100)
        gravity.categoryBitMask = gravityCategory
        //self.addChild(gravity)
        //        //self.physicsWorld.gravity =
        //
        let spring = SKFieldNode.springField()
        spring.strength = 0.2
        spring.position = CGPoint(x: (midPoint?.x)!, y: (midPoint?.y)!)
        spring.categoryBitMask = springFieldCategory
        self.addChild(spring)
        
        self.physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
    }
    
    var touchLocation:CGPoint = CGPoint(x: 0, y: 0)
    
    func touchDown(atPoint pos : CGPoint) {
        touchLocation = pos
        for sprite in nodes {
            if sprite.contains(pos){
                sprite.physicsBody?.isDynamic = false
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        for sprite in nodes {
            if sprite.contains(pos) {
                if sprite.contains(touchLocation) {
                    guard let index = Int(nodes[Int(sprite.name!)!].name!) else {
                        continue
                    }
                    
                    transitionDelegate?.Transition(position:sprite.position,size:sprite.size.width,image:UIImage(cgImage: (sprite.texture?.cgImage())!),user:users[index])
                }
                
                if pos.x == 0.5 {
                    print("\(nodes[Int(sprite.name!)!].name)")
                    let properties:[String : Any] = ["selection": 0]
                    if let index = Int(nodes[Int(sprite.name!)!].name!) {
                      //selectUserWithProperties(properties: properties as [String : AnyObject],user:users[index])
                    }
                    self.removeChildren(in: [sprite])
                }
                
                if pos.x == (midPoint?.x)!*2-0.5 {
                    print("\(nodes[Int(sprite.name!)!].name)")
                    let properties:[String : Any] = ["selection": 1]
                    if let index = Int(nodes[Int(sprite.name!)!].name!) {
                        //selectUserWithProperties(properties: properties as [String : AnyObject],user:users[index])
                    }
                    self.removeChildren(in: [sprite])
                }
                
                if pos.y == 0.5 {
                    print("\(nodes[Int(sprite.name!)!].name)")
                    let properties:[String : Any] = ["selection": 2]
                    if let index = Int(nodes[Int(sprite.name!)!].name!) {
                        //selectUserWithProperties(properties: properties as [String : AnyObject],user:users[index])
                    }
                    self.removeChildren(in: [sprite])
                }
                
                if pos.y == (midPoint?.y)!*2-0.5 {
                    print("\(nodes[Int(sprite.name!)!].name)")
                    let properties:[String : Any] = ["selection": 3]
                    if let index = Int(nodes[Int(sprite.name!)!].name!) {
                        //selectUserWithProperties(properties: properties as [String : AnyObject],user:users[index])
                    }
                    self.removeChildren(in: [sprite])
                }
                
                sprite.physicsBody?.isDynamic = true
            }
        }
    }
    
    
    private func selectUserWithProperties(properties :[String: AnyObject],user:User) {
        let ref = FIRDatabase.database().reference().child("user_selection")
        let childRef = ref.childByAutoId()
        let toId = user.id
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        
        var values = ["toId": toId as Any, "fromId": fromId as Any, "timestamp": timestamp] as [String : Any]
        
        //apend
        properties.forEach({values[$0] = $1})
        
        //childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (error, ref) in            
            if error != nil {
                print(error as Any)
                return
            }
            
            let userMessagesRef = FIRDatabase.database().reference().child("user_selection").child(fromId!).child(toId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user_selection").child(toId!).child(fromId!)
            recipientUserMessagesRef.updateChildValues([messageId:1])
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
//                for sprite in nodes {
//                    if sprite.contains(touch.location(in: self)) {
//                        print(sprite.name as Any)
//                    }
//                }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    func handleLogout(){
        do{
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        transitionDelegate?.handleLoginLogout()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let location = touch.location(in: self)
        
        for sprite in nodes {
            if sprite.contains(location) {
                sprite.position = touch.location(in: self)
                
            }
        }
        for t in touches {
            self.touchMoved(toPoint: t.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //         //Called before each frame is rendered
        //        for node1 in nodes {
        //            for node2 in nodes {
        //                let m1 = node1.physicsBody!.mass * strength
        //                let m2 = node2.physicsBody!.mass * strength
        //                let disp = CGVector(dx: node2.position.x-node1.position.x, dy: node2.position.y-node1.position.y)
        //                let radius = sqrt(disp.dx*disp.dx+disp.dy*disp.dy)
        //                if radius < radiusLowerBound { //Radius lower-bound.
        //                    continue
        //                }
        //                let force = (m1*m2)/(radius*radius);
        //                let normal = CGVector(dx: disp.dx/radius, dy: disp.dy/radius)
        //                let impulse = CGVector(dx: normal.dx*force*dt, dy: normal.dy*force*dt)
        //
        //                node1.physicsBody!.velocity = CGVector(dx: node1.physicsBody!.velocity.dx + impulse.dx, dy: node1.physicsBody!.velocity.dy + impulse.dy)
        //            }
        //        }
        
    }
    
    let imageCache = NSCache<NSString, AnyObject>()
    
    func loadImageUsingCacheUrlString(urlString:String) {
        if imageCache.object(forKey: urlString as NSString) != nil {
            return
        }
        
        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            if let image = UIImage(data: data!) {
                self.imageCache.setObject(image, forKey: urlString as NSString)
            }
        }
        
        task.resume()
        
    }
    
    func fetchUser(){
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                let url = URL(string: user.profile_image_url!)
                
                let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    
                    if let image = UIImage(data: data!) {
                        self.imageCache.setObject(image, forKey: user.profile_image_url! as NSString)
                        self.setBubbles(image: image)
                        //self.updateData()
                    }
                }
                
                task.resume()
            }
            
        }, withCancel: {(completed) in
            
        })
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            performSelector(inBackground: #selector(handleLogout), with: nil)
        } else {
            //continue
        }
    }
    
    func setBubbles(image:UIImage){
        self.nodeCategories.append(0b1 << UInt32(nodes.count))
        let randomInt = Int(arc4random_uniform(40))
        let sizeOfNode = CGSize(width: self.minimumSize! + randomInt, height: self.minimumSize! + randomInt)
        
        let profile_pic = SKTexture(image: UIImage.roundedRectImageFromImage(image: image/*UIImage(named:"default_profile_photo")!*/, imageSize: sizeOfNode, cornerRadius: sizeOfNode.width/2))
        let circularProfile = SKSpriteNode(texture: profile_pic)
        circularProfile.name = (nodes.count).description
        
        //circularProfile.size = sizeOfNode
        circularProfile.physicsBody = SKPhysicsBody(circleOfRadius: max(circularProfile.size.width / 2, circularProfile.size.height / 2))
        
        circularProfile.position = CGPoint(x: self.frame.midX + CGFloat(nodes.count), y: circularProfile.size.height)
        
        let cropNode = SKCropNode()
        cropNode.maskNode = circularProfile
        
        
        circularProfile.physicsBody?.categoryBitMask = self.nodeCategories[nodes.count]
        circularProfile.physicsBody?.fieldBitMask = self.gravityCategory | self.springFieldCategory
        
        //check if you want rotation or not
        circularProfile.physicsBody?.allowsRotation = false
        self.nodes.append(circularProfile)
        self.addChild(circularProfile)
    }
    
    
}






