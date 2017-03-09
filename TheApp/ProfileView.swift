//
//  ProfileViewController.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 3/2/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class ProfileView: UIView {
    
    var dalegate:ProfileTransition?
    
    var user:User? {
        didSet{
            nameLabel.text = user?.email
        }
    }
    
    var images:[UIImageView] = [UIImageView()]
    
    let navBarView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        return view
    }()
    
    let profileImagesView:UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel()
        //label.backgroundColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var backLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBack)))
        label.text = "Back"
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var imagesScrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .gray
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    func handleBack(){
        dalegate?.handleBack()
    }
    
    var navBarViewTopAnchor:NSLayoutConstraint?
    var imageScrollViewTopAnchor:NSLayoutConstraint?
    
    override init(frame:CGRect){
       super.init(frame: frame)
        
        for imageview in images{
            imageview.image = #imageLiteral(resourceName: "profile")
            imagesScrollView.addSubview(imageview)
            imageview.frame = imagesScrollView.bounds
        }
        
        // Do any additional setup after loading the view.
        backgroundColor = .purple
        //addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDissmiss)))
        
        //        view.addSubview(profileImageView)
        //
        //        profileImageView.topAnchor.constraint(equalTo: view.topAnchor,constant:100).isActive = true
        //        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        //        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
//        addSubview(nameLabel)
//        
//        nameLabel.topAnchor.constraint(equalTo: topAnchor,constant:50).isActive = true
//        nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        nameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(navBarView)
        
        navBarViewTopAnchor = navBarView.topAnchor.constraint(equalTo: topAnchor,constant:-50)
        navBarViewTopAnchor?.isActive = true
        navBarView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        navBarView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        navBarView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        navBarView.addSubview(backLabel)
        
        backLabel.leftAnchor.constraint(equalTo: navBarView.leftAnchor,constant: 8).isActive = true
        backLabel.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor,constant:-8).isActive = true
        backLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        backLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

        addSubview(imagesScrollView)
        print(frame.height)
        imageScrollViewTopAnchor = imagesScrollView.topAnchor.constraint(equalTo: topAnchor,constant: 1000)
        imageScrollViewTopAnchor?.isActive = true
        imagesScrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imagesScrollView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        imagesScrollView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    
    func showImageSrollView(){
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.imageScrollViewTopAnchor?.constant = 100
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
    }
    
    func hideImageSrollView(){
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.imageScrollViewTopAnchor?.constant = 1000
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
    }

    
    
    func showNavBar(){
       UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.navBarViewTopAnchor?.constant = 0
        self.layoutIfNeeded()
       }) { (completed) in
        
        }
    }
    
    func hideNavBar(){
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.navBarViewTopAnchor?.constant = -50
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//class ProfileLauncher:NSObject{
//    
//    func showProfileView(position:CGPoint,size:CGFloat){
//        print("Showing VideoPlayer")
//        
//        if let keyWindow = UIApplication.shared.keyWindow {
//            let view = UIView(frame: keyWindow.frame)
//            view.backgroundColor = .white
//            
//            view.frame = CGRect(x: position.x, y: position.y, width: 10, height: 10)
//            
//            let height = keyWindow.frame.width * 9 / 16
//            let videoPlayerFrame = CGRect(x: 0, y: 0, width: size, height: size)
//            
//            let videoPlayer = ProfileView(frame: videoPlayerFrame)
//            view.addSubview(videoPlayer)
//            
//            keyWindow.addSubview(view)
//            
////            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
////                view.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
////            }, completion: { (compltedAnimation) in
////                //UIApplication.shared.setStatusBarHidden(true, with: .fade)
////            })
//        }
//        
//    }
//}

