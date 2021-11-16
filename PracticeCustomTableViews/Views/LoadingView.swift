//
//  LoadingController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/15/21.
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    var loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.style = .large
        indicator.color = .white
            
        // The indicator should be animating when
        // the view appears.
        indicator.startAnimating()
            
        // Setting the autoresizing mask to flexible for all
        // directions will keep the indicator in the center
        // of the view and properly handle rotation.
        indicator.autoresizingMask = [
            .flexibleLeftMargin, .flexibleRightMargin,
            .flexibleTopMargin, .flexibleBottomMargin
        ]
            
        return indicator
    }()
   
     
    var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.alpha = 0.8
        
        // Setting the autoresizing mask to flexible for
        // width and height will ensure the blurEffectView
        // is the same size as its parent view.
        blurEffectView.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]
        
        return blurEffectView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
           
           // Add the blurEffectView with the same
           // size as view
        blurEffectView.frame = self.bounds
        self.insertSubview(blurEffectView, at: 0)
           
           // Add the loadingActivityIndicator in the
           // center of view
           loadingActivityIndicator.center = CGPoint(
               x: self.bounds.midX,
               y: self.bounds.midY
           )
           self.addSubview(loadingActivityIndicator)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

