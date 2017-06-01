//
//  OnboardingViewController.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/22/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    var cellId = "cellId"
    var loginCellId = "loginCellId"
    var backGroundColors:[UIColor] = [.purple,.red,.brown,.cyan]
    
    let pages:[OnboardingPage] = {
        let firstPage = OnboardingPage(title: "Share a greate listen", message: "sadas as das d asdsadas asd asd  asd as  asd ")
        let secondPage = OnboardingPage(title: "Share a greate listen", message: "sadas as das d asdsadas asd asd  asd as  asd ")
        let thirdPage = OnboardingPage(title: "Share a greate listen", message: "sadas as das d asdsadas asd asd  asd as  asd ")
        
        return [firstPage,secondPage,thirdPage]
    }()
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.delegate = self
        view.isPagingEnabled = true
        view.dataSource = self
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    lazy var  pageControl:UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = UIColor.darkGray
        pc.numberOfPages = self.pages.count + 1
        return pc
    }()
    
    let skipButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor(white: 0.4, alpha: 1), for: .normal)
        return button
    }()
    
    let nextButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor(white: 0.4, alpha: 1), for: .normal)
        return button
    }()
    
    var pageControlBottomAnchor:NSLayoutConstraint?
    var nextTopBottomAnchor:NSLayoutConstraint?
    var skipTopBottomAnchor:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        registerCells()
        
        pageControlBottomAnchor = pageControl.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)[1]
        skipTopBottomAnchor = skipButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50).first
        nextTopBottomAnchor = nextButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50).first
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageNumer = Int(targetContentOffset.pointee.x / view.frame.width)
        pageControl.currentPage = pageNumer
        
        if pageNumer == pages.count {
            pageControlBottomAnchor?.constant = 40
            skipTopBottomAnchor?.constant = -40
            nextTopBottomAnchor?.constant = -40
        } else {
            pageControlBottomAnchor?.constant = 0
            skipTopBottomAnchor?.constant = 16
            nextTopBottomAnchor?.constant = 16
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func registerCells(){
        collectionView.register(OnboardingPageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LoginPageCell.self, forCellWithReuseIdentifier: loginCellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == pages.count {
           let loginCell = collectionView.dequeueReusableCell(withReuseIdentifier: loginCellId, for: indexPath)
            return loginCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OnboardingPageCell
        cell.page = pages[indexPath.item]
        
        return cell
    }
}
