//
//  ChatInputContainerView.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/22/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class ChatInputContainerView :UIView , UITextFieldDelegate{
   
    
    var chatLogController:ChatLogController? {
       didSet{
        sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTapGesture)))
       }
    }
    
    lazy var cameraView: UIView = {
        
        let view = UIView()
        view.layer.cornerRadius = 22
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        //view.alpha = 0
        
        let cameraOptionButton = UIImageView()
        cameraOptionButton.isUserInteractionEnabled = true
        cameraOptionButton.image = UIImage(named: "photo-camera")?.withRenderingMode(.alwaysTemplate)
        cameraOptionButton.contentMode = .scaleAspectFill
        cameraOptionButton.tintColor = .white
        cameraOptionButton.translatesAutoresizingMaskIntoConstraints = false
        cameraOptionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCameraViewAnimation)))
        cameraOptionButton.isUserInteractionEnabled = true
        
        view.addSubview(cameraOptionButton)
        
        cameraOptionButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        cameraOptionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -12).isActive = true
        cameraOptionButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        cameraOptionButton.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        let uploadPhoto = UIImageView()
        uploadPhoto.isUserInteractionEnabled = true
        uploadPhoto.image = UIImage(named: "photo_icon")
        uploadPhoto.contentMode = .scaleAspectFill
        uploadPhoto.translatesAutoresizingMaskIntoConstraints = false
        uploadPhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handlePhoto)))
        
        view.addSubview(uploadPhoto)
        
        uploadPhoto.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4).isActive = true
        uploadPhoto.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        uploadPhoto.widthAnchor.constraint(equalToConstant: 36).isActive = true
        uploadPhoto.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        let uploadVideo = UIImageView()
        uploadVideo.isUserInteractionEnabled = true
        uploadVideo.image = UIImage(named: "video_icon")
        uploadVideo.contentMode = .scaleAspectFill
        uploadVideo.translatesAutoresizingMaskIntoConstraints = false
        uploadVideo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleVideo)))
        
        view.addSubview(uploadVideo)
        
        uploadVideo.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4).isActive = true
        uploadVideo.topAnchor.constraint(equalTo: view.topAnchor , constant: 4).isActive = true
        uploadVideo.widthAnchor.constraint(equalToConstant: 36).isActive = true
        uploadVideo.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        
        return view
    }()
    
    func handleVideo(){
      print("Video Selected")
    
    }
    
    func handlePhoto(){
        print("photo Selected")
        
    }
    
    func showCameraOptionsAnimated(){
        print("uploadButtonPressed")
        handleCameraViewAnimation()
    }
    
    func handleCameraViewAnimation(){
        print("in camera animation")
        
        cameraView.becomeFirstResponder()
        //self.resignFirstResponder()
        
        if self.cameraViewHeightAnchor?.constant == 44 {
             UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                self.cameraViewHeightAnchor?.constant = 150
                self.cameraView.alpha = 1
                self.layoutIfNeeded()
             }, completion: { (completion) in
                
             })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.cameraViewHeightAnchor?.constant = 44
                self.cameraView.alpha = 0
                self.layoutIfNeeded()
            }, completion: { (completion) in
                
            })
        }
    }
    
    lazy var inputTextField: UITextField = {
        var field = UITextField()
        field.placeholder = "Enter message..."
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        return field
    }()
    
    var uploadImageView:UIImageView = {
       let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "photo-camera")
        uploadImageView.contentMode = .scaleAspectFill
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    var sendButton:UIButton = {
       var sendButton  = UIButton()
        sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    
    var cameraViewHeightAnchor:NSLayoutConstraint?
    
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(cameraView)
        
        cameraView.leftAnchor.constraint(equalTo: leftAnchor, constant:4).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: bottomAnchor ,constant: -4).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        cameraViewHeightAnchor = cameraView.heightAnchor.constraint(equalToConstant: 150)
        cameraViewHeightAnchor?.isActive = true
        
        addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(self.inputTextField)
        //x,y,w,hu
        self.inputTextField.leftAnchor.constraint(equalTo: (cameraView.rightAnchor), constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: (sendButton.leftAnchor)).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
