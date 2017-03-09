//
//  OnboardingCell.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/22/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class OnboardingPageCell:UICollectionViewCell{
  
    var page:OnboardingPage? {
        didSet{
           
            guard let page = page else {
                return
            }
            
            let color = UIColor.white
            let attributedText = NSMutableAttributedString(string: page.title, attributes: [NSFontAttributeName :UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), NSForegroundColorAttributeName:color])
            
            attributedText.append(NSAttributedString(string: "\n\n\(page.message)", attributes: [NSFontAttributeName :UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName:color]))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let length = attributedText.string.characters.count
            attributedText.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location:0,length:length))
            
            //textView.text = page.title + "\n\n" + page.message
            textView.attributedText = attributedText
        }
    }
    
    override init(frame:CGRect){
        super.init(frame:frame)
        
      setupViews()
    }
    
    let textView: UITextView = {
        let view = UITextView()
        view.text = "Sample Text"
        view.isEditable = false
        view.backgroundColor = UIColor(white: 0.4, alpha: 1)
        view.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        return view
    }()
    
    let lineSeperator:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return view
    }()
    
    func setupViews(){
        addSubview(textView)
        
        backgroundColor = .white
        
        textView.anchorWithConstantsToTop(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 16)
        textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        
        //addSubview(lineSeperator)
        //lineSeperator.topAnchor(nil, left: leftAnchor, bottom: textView.bottomAnchor, right: rightAnchor)
        //lineSeperator.heightAnchor.constraint(equalToConstant: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
