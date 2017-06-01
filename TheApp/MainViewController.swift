//
//  MainViewController.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 3/2/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase

class MainViewController: UIViewController, ProfileTransition,MainMenuDelegate {
    
    
    let meassageController:MessagesController = {
        let controller = MessagesController()
        return controller
    }()
    
    let loginController:LoginController = {
        let controller = LoginController()
        return controller
    }()
    
    lazy var profleView:ProfileView = {
        let view = ProfileView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.dalegate = self
        return view
    }()
    
    lazy var scene:MainScene = {
        let scene = MainScene(size: self.view.bounds.size)
        scene.size = self.view.bounds.size
        scene.scaleMode = .resizeFill
        scene.midPoint = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        scene.transitionDelegate = self
        return scene
    }()
    
    lazy var skView:SKView = {
        let view = SKView()
//        let scene = MainScene(size: view.bounds.size)
//        scene.size = view.bounds.size
//        scene.scaleMode = .resizeFill
//        scene.midPoint = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
//        scene.transitionDelegate = self
        view.presentScene(self.scene)
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()
    
    var transationStartPoint:CGPoint?
    
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    var currentRadius:CGFloat = 0.0
    
//    override var prefersStatusBarHidden: Bool {
//        return false
//    }
    
//    func observemessages(){
//        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
//            return
//        }
//        
//        let userMessageRef = FIRDatabase.database().reference().child("user_selection").child(uid).child(toId)
//        userMessageRef.observe(.childAdded, with: { (snapshot) in
//            
//            print(snapshot)
//            
//            //let messageId = snapshot.key
//            //let messagesRef = FIRDatabase.database().reference().child("selection").child(messageId)
//            //messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            guard let dictionary = snapshot.value as? [String:AnyObject] else {
//                return
//            }
//            
//            //self.messages.append(Message(dictionary: dictionary))
//            
//            DispatchQueue.main.async {
//                // self.collectionView?.reloadData()
//                //scroll to last index
//                //let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
//                //self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
//            }
//            
//            //}, withCancel: nil)
//            
//            
//        }, withCancel: nil)
//    }
    
    var usersSelected = [String:[Int]]()
    var matchedUsers:[String:Int] = [:]
    
    func obserUserSelection(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user_selection").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            //print(snapshot)
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user_selection").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                self.fetchMessageWithMessageId(messageId: snapshot.key,uid:uid)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            print(snapshot.key)
            self.matchedUsers.removeValue(forKey: snapshot.key)
            //self.messagesDictionary.removeValue(forKey: snapshot.key)
            //self.attemtrelodTable()
            
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageId(messageId:String,uid:String){
        
        let messageReference = FIRDatabase.database().reference().child("user_selection").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //print(snapshot)
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                //print(dictionary)
                
                guard let fromId = dictionary["fromId"] as? String,let toId = dictionary["toId"] as? String,let selection = dictionary["selection"] as? Int else {
                   return
                }
                
                if let chatPartnerId = self.chatPartnerId(fromId:fromId,toId:toId) {
                    
                    if uid == fromId {
                        if self.usersSelected[chatPartnerId] != nil {
                            self.usersSelected[chatPartnerId]?.append(selection)
                        } else {
                           self.usersSelected[chatPartnerId] = [selection]
                        }
                     }
                    
                    if toId == uid {
                        if self.usersSelected[chatPartnerId] != nil {
                            self.usersSelected[chatPartnerId]?.append(selection)
                        } else {
                            self.usersSelected[chatPartnerId] = [selection]
                        }
                        
                    }
                }
                
                //self.usersSelected[uid] = dictionary["toId"] as! String
                
                //print(self.usersSelected)
                
                for user in self.usersSelected {
                    print(user.key)
                    
                    if user.value.count >= 2 {
                        if user.value[0] == user.value[1] {
                            self.matchedUsers[user.key] = selection
                            print(self.matchedUsers)
                        }
                    }
                }
                
                //let message = Message(dictionary: dictionary)
                //self.messages.append(message)
                //if let chatPartnerId = message.chatPartnerId() {
                    //self.messagesDictionary[chatPartnerId] = message
                //}
                
            }
        }, withCancel: nil)
    }
    
    func chatPartnerId(fromId:String,toId:String) -> String? {
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
    
    lazy var topSlideView:TopSlideMenu = {
        let view = TopSlideMenu()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    var topSlideViewTopConstrain:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //observemessages()
        obserUserSelection()
        
        print("in the view Did load")
        
        view.backgroundColor = .white
        
        view.addSubview(skView)
        skView.frame = view.bounds
        
        //skView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //skView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        //skView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        //skView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        //skView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: <#T##CGFloat#>)
        
        view.addSubview(topSlideView)
        
        topSlideViewTopConstrain = topSlideView.topAnchor.constraint(equalTo: view.topAnchor)
        topSlideViewTopConstrain?.isActive = true
        topSlideView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topSlideView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        topSlideView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleTopEdgeSwipe))
        screenEdgeRecognizer.edges = .top
        view.addGestureRecognizer(screenEdgeRecognizer)
        
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleTopEdgeSwipeClose))
//        topSlideView.addGestureRecognizer(gesture)
        
        //self.view.addGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        //createPanGestureRecognizer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //self.topSlideViewTopConstrain?.constant = -50
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
    }
    
    func handleTopEdgeSwipe(sender: UIScreenEdgePanGestureRecognizer){
      if sender.state == .ended {
          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            self.topSlideViewTopConstrain?.constant = 0
            self.view.layoutIfNeeded()
          }, completion: { (completed) in
            
          })
        }
    }
    
    func handleTopEdgeSwipeClose(sender: UIPanGestureRecognizer){
        if sender.state == .ended {
            //topSlideViewTopConstrain?.constant = -50
        }
    }
    
    // The Pan Gesture
    func createPanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        // get translation
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)
        print(translation)
        
        //if Int((topSlideViewTopConstrain?.constant)!) <= 0 {
           //topSlideViewTopConstrain?.constant = (topSlideViewTopConstrain?.constant)! + translation.y
        //}
        
        // create a new Label and give it the parameters of the old one
//        var label = panGesture.view as! UIImageView
//        label.center = CGPoint(x: label.center.x+translation.x, y: label.center.y+translation.y)
//        label.isMultipleTouchEnabled = true
//        label.isUserInteractionEnabled = true
        
        if panGesture.state == UIGestureRecognizerState.began {
            // add something you want to happen when the Label Panning has started
            print(1)
        }
        
        if panGesture.state == UIGestureRecognizerState.ended {
            // add something you want to happen when the Label Panning has ended
            print(2)
        }
        
        if panGesture.state == UIGestureRecognizerState.changed {
            // add something you want to happen when the Label Panning has been change ( during the moving/panning )
            print(3)
        } else {  
            // or something when its not moving
            print(4)
        }    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
    }
    
    func handleMessageController(){
        let messageController = MessagesController()
        messageController.matchedUsers = matchedUsers
        let controller = UINavigationController(rootViewController: messageController)
        present(controller, animated: true, completion: nil)
    }
    
    func handleLoginLogout(){
        //usersSelected = [:]
        //matchedUsers = [:]
        present(loginController, animated: true, completion: nil)
    }
    
    var shouldOpen = true
    
    lazy var profileImageView:UIImageView = {
        let view = UIImageView()
        //view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTouch)))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    func handleBack(){
       handleTouch()
    }
    
    func handleTouch(){
        
        self.view.addSubview(self.skView)
        self.skView.alpha = 0
        self.skView.frame = self.view.bounds
        self.scene.isPaused = false
        self.view.layoutIfNeeded()
        
        self.profleView.hideNavBar()
        self.profleView.hideImageSrollView()
        
        UIView.animate(withDuration: 0.3, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.profileImageViewLeftAnchor?.constant = (self.transationStartPoint?.x)! - (self.transationBubbleRadius)!
            self.profileImageViewBottomAnchor?.constant = -((self.transationStartPoint?.y)! - (self.transationBubbleRadius!))
            self.profileImageViewWidthAnchor?.constant = (self.transationBubbleRadius!)*2
            self.profileImageViewHeightAnchor?.constant = (self.transationBubbleRadius!)*2
            self.skView.alpha = 1
            self.profileImageView.layer.cornerRadius = 0
            self.view.layoutIfNeeded()
        }) { (completed) in
//            self.view.addSubview(self.skView)
//            self.skView.frame = self.view.bounds
            self.profileImageView.removeFromSuperview()
            self.profleView.removeFromSuperview()
        }
    }
    
    var profileImageViewBottomAnchor:NSLayoutConstraint?
    var profileImageViewLeftAnchor:NSLayoutConstraint?
    var profileImageViewHeightAnchor:NSLayoutConstraint?
    var profileImageViewWidthAnchor:NSLayoutConstraint?
    var transationBubbleRadius:CGFloat?
    
    func Transition(position:CGPoint,size:CGFloat,image:UIImage,user:User){
        
        let radius = size/2.00
        
        view.addSubview(profleView)
        profleView.alpha = 0
        //profleView.frame = view.bounds
        
        profleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        profleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profleView.widthAnchor.constraint(equalTo: view.widthAnchor,constant:-20).isActive = true
        profleView.heightAnchor.constraint(equalTo: view.heightAnchor,constant:-20).isActive = true

        
        view.addSubview(profileImageView)
        //profileImageView.layer.cornerRadius = radius
        
        
        print(radius)
        
        transationStartPoint = position
        transationBubbleRadius = radius
        profileImageView.image = image
        
        profileImageViewBottomAnchor  = profileImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant:-(position.y-radius))
        profileImageViewBottomAnchor?.isActive = true
        profileImageViewLeftAnchor = profileImageView.leftAnchor.constraint(equalTo: view.leftAnchor,constant:position.x-radius)
        profileImageViewLeftAnchor?.isActive = true
        profileImageViewHeightAnchor = profileImageView.heightAnchor.constraint(equalToConstant: radius*2)
        profileImageViewHeightAnchor?.isActive = true
        profileImageViewWidthAnchor = profileImageView.widthAnchor.constraint(equalToConstant: radius*2)
        profileImageViewWidthAnchor?.isActive = true
        self.view.layoutIfNeeded()
        
        scene.isPaused = true
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.profileImageViewLeftAnchor?.constant = 8
            self.profileImageViewBottomAnchor?.constant = 300-(self.view.frame.height + self.view.frame.width/3)
            self.profileImageViewWidthAnchor?.constant = self.view.frame.width/6
            self.profileImageViewHeightAnchor?.constant = self.view.frame.width/6
            self.profileImageView.layer.cornerRadius = (self.view.frame.width/3)/2
            self.skView.alpha = 0
            self.profleView.alpha = 1
            self.view.layoutIfNeeded()
        }) { (completed) in
            self.skView.removeFromSuperview()
            self.profleView.showNavBar()
            self.profleView.showImageSrollView()
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
