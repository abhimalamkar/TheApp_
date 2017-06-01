//
//  TopSlideMenu.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 3/8/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class TopSlideMenu: UIView {

    var delegate:MainMenuDelegate?
    
    lazy var rightButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"new_message_icon"), for: .normal)
        button.addTarget(self, action: #selector(self.handleRightButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var leftButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"new_message_icon"), for: .normal)
        button.addTarget(self, action: #selector(self.handleLeftButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func handleRightButton() {
        print("Right Working")
        delegate?.handleMessageController()
    }
    
    func handleLeftButton(){
        print("Left Working")
        delegate?.handleLoginLogout()
    }
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        addSubview(rightButton)
        
        rightButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: 8).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(leftButton)
        
        leftButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: 8).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        leftButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
