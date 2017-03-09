//
//  LoginPageCell.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/23/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class LoginPageCell: UICollectionViewCell{
   
    override init(frame:CGRect){
        super.init(frame:frame)
        
        setupViews()
    }
    
    func setupViews(){
       
       backgroundColor = UIColor(r: 61, g: 91, b: 151)
   }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
