//
//  CircularTransition.swift
//  MyApp
//
//  Created by Abhijeet Malamkar on 2/9/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit

class CircularTransition: NSObject {
    
    var circle = UIView()
    
    var startingpoint = CGPoint.zero {
        didSet {
            circle.center = startingpoint
        }
    }

    var circleColor = UIColor.white
    
    var duration = 0.3
    
    enum CircularTransitionMode:Int {
     case present, dissmiss, pop
    }
    
    var transitionMode:CircularTransitionMode = .present
}


extension CircularTransition:UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
         return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        if transitionMode == .present
        {
            if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to){
            
                let viewCenter = presentedView.center
                let viewSize = presentedView.frame.size
                
                circle = UIView()
                
                circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingpoint)
                
                circle.layer.cornerRadius = circle.layer.frame.width / 2
                circle.center = startingpoint
                circle.backgroundColor = circleColor
                containerView.addSubview(circle)
                
                circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                
                presentedView.center = startingpoint
                presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

                presentedView.alpha = 0
                containerView.addSubview(presentedView)
                
                UIView.animate(withDuration: duration, animations: {
                 self.circle.transform = CGAffineTransform.identity
                    presentedView.transform = CGAffineTransform.identity
                    presentedView.alpha = 1
                    presentedView.center = viewCenter
                    
                }, completion: { (success:Bool) in
                    transitionContext.completeTransition(success)
                })
            }
        }
        else
        {
            let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            
            if let returnvView = transitionContext.view(forKey: transitionModeKey) {
            
                let viewCenter = returnvView.center
                let viewSize = returnvView.frame.size
                
                circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingpoint)
                
                circle.layer.cornerRadius = circle.layer.frame.width / 2
                circle.center = startingpoint

                UIView.animate(withDuration: duration, animations: {
                    self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    returnvView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    returnvView.center = self.startingpoint
                    returnvView.alpha = 0
                    
                    if self.transitionMode == .pop {
                    
                        containerView.insertSubview(returnvView, belowSubview: returnvView)
                        containerView.insertSubview(self.circle, belowSubview: returnvView)
                    }
                    
                }, completion: { (success:Bool) in
                    returnvView.center = viewCenter
                    returnvView.removeFromSuperview()
                    
                    self.circle.removeFromSuperview()
                    
                    transitionContext.completeTransition(success)
                })
            }
        }
        
    }
    
    
    func frameForCircle(withViewCenter viewCenter:CGPoint,size viewSize:CGSize,startPoint:CGPoint) -> CGRect {
    
        let xlenght = fmax(startingpoint.x, viewSize.width - startingpoint.x)
        let ylenght = fmax(startingpoint.y, viewSize.height - startingpoint.y)
        
        let offSetVector = sqrt(xlenght * xlenght + ylenght * ylenght) * 2
        let size = CGSize(width: offSetVector, height: offSetVector)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
    
}
