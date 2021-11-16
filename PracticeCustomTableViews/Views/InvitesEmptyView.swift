//
//  InvitesEmptyView.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/15/21.
//

import Foundation
import UIKit

class InvitesEmptyView: UIView {
    
    var label: UILabel = {
        var label = UILabel()
        label.text = "We'll let you know when you get some 👌🏼"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        return label
    }()
    
    var imageView: UIImageView = {
    var iv = UIImageView()
        iv.image = UIImage(named: "noinvites")
    return iv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.white
        self.addSubview(imageView)
        imageView.setDimensions(width: 200, height: 300)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.anchor(top: self.topAnchor, paddingTop: 100)
        imageView.centerX(inView: self)
        
        self.addSubview(label)
        label.anchor(top: imageView.bottomAnchor, paddingTop: 0, width: 300, height: 50)
        label.textAlignment = .center
        label.centerX(inView: self)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
