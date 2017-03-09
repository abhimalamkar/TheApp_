//
//  Onboarding.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/27/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class Onboarding: UIViewController {

    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: 50))
        return chatInputContainerView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .purple
        
        view.addSubview(inputContainerView)
    }

}
