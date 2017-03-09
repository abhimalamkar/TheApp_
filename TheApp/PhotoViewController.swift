//
//  PhotoViewController.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/25/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    var takenPhoto:UIImage?
    
    lazy var photoImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUiImageTap)))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    func handleUiImageTap(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(photoImageView)
        photoImageView.image = takenPhoto
        photoImageView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
