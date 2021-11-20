//
//  JustsHeader.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/19/21.
//

import UIKit
import Foundation

class JustsHeader: UICollectionReusableView {
      
    var date: String? {
        didSet {
            configure()
        }
    }
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        
        return view
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    func configure() {
        guard let date = date else { return }
        self.label.text = date
        
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycles
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        self.backgroundColor = .clear
        self.addSubview(label)
        label.centerY(inView: self)
        label.anchor(left: self.leftAnchor, right: self.rightAnchor, paddingLeft: 20, paddingRight: 20)
        overrideUserInterfaceStyle = .light
    }
}
