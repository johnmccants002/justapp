//
//  JustDetailsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 12/4/21.
//

import Foundation
import UIKit

class JustDetailsController: UIViewController {
    
    // MARK: - Properties
    
    var just: Just?
    var detailsView: UIView?
    var detailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Details"
    
        return label
    }()
    
    var justDetailsLabel = UILabel()
    var justDetailsImage : UIImage?
    var detailsImageView: UIImageView = UIImageView()
    
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewGesture()
    }
    
    // MARK: - Helper Functions
    
    func setupViewGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.view.addGestureRecognizer(tap)
    }

    
    func setupView() {
        self.view.backgroundColor = .clear
        let detailsView = UIView()
        detailsView.backgroundColor = .white
        detailsView.setRoundedView()
        self.detailsView = detailsView
        self.view.addSubview(detailsView)
        detailsView.anchor(width: self.view.viewWidth - 40, height: 500)
        detailsView.centerX(inView: self.view)
        detailsView.centerY(inView: self.view)
        detailsView.addSubview(detailTitleLabel)
        detailTitleLabel.anchor(top: detailsView.topAnchor, paddingTop: 15, width: 50, height: 20)
        detailTitleLabel.centerX(inView: detailsView)
        detailTitleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        detailTitleLabel.attributedText = NSAttributedString(string: "Details", attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        detailsView.addSubview(justDetailsLabel)
        
        

        
        if let just = just {
            if let url = just.justImageUrl {
                self.detailsImageView.sd_setImage(with: url) { image, error, cache, url in
                    if image != nil {
                        self.setupWithImageView()
                        self.detailsImageView.setupImageViewer()
                    }
                }
            } else {
            if let details = just.details {
                self.justDetailsLabel.text = details
                justDetailsLabel.centerX(inView: detailsView)
                justDetailsLabel.centerY(inView: detailsView)
                justDetailsLabel.setDimensions(width: 300, height: 100)
                justDetailsLabel.numberOfLines = 7
                justDetailsLabel.textAlignment = .center
                justDetailsLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                
                switch details.count {
                case 0...100 :
                    detailsView.anchor(height: 150)
                case 101...350 :
                    detailsView.anchor(height: 200)
                    justDetailsLabel.anchor(height: 200)
                default:
                    break
                }
                
            }
            }
        }
        
        
    }
    
    func setupWithImageView() {
        if let detailsView = detailsView {
            detailsView.addSubview(detailsImageView)
            detailsImageView.anchor(top: detailTitleLabel.bottomAnchor, paddingTop: 40, width: 200, height: 200)
            detailsImageView.centerX(inView: detailsView)
            detailsImageView.layer.borderWidth = 1
            detailsImageView.layer.borderColor = UIColor.black.cgColor
            if let just = just {
                if let details = just.details {
                    justDetailsLabel.text = details
                }
            }
            justDetailsLabel.font = UIFont(name: "HelveticaNeue", size: 14)
            justDetailsLabel.anchor(top: detailsImageView.bottomAnchor, width: 300, height: 150)
            justDetailsLabel.textAlignment = .center
            justDetailsLabel.centerX(inView: detailsView)
            justDetailsLabel.numberOfLines = 7
        }
        
    }
    
    // MARK: - Selectors
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
