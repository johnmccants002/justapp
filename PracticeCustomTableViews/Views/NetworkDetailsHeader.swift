//
//  NetworkDetailsHeader.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/15/21.
//

import Foundation
import UIKit

class NetworkDetailsHeader: UICollectionReusableView {
    
    var count: Int? {
        didSet {
            configure()
        }
    }
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightText
        
        return view
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    func configure() {
        guard let count = count else { return }
        if count == 1 {
            self.label.text = "No one in your network"
        } else if count > 1 {
            self.label.text = "\(count) people in your network"
        } else {
            self.label.isHidden = true
        }
        
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
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        self.backgroundColor = .systemGray5
        self.addSubview(label)
        label.centerY(inView: self)
        label.anchor(left: self.leftAnchor, paddingLeft: 20)
    }
    
}
