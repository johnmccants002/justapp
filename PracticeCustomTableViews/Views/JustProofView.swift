//
//  JustProofView.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/4/21.
//

import UIKit

class JustProofView: UIView {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var justImageView: UIImageView!
    @IBOutlet weak var justTextView: UITextView!
    var delegate : JustProofViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        animate()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
    }

    func animate() {
        self.transform = .identity
        self.slideIn(from: .bottom, x: 1, y: 1, duration: 1.5, delay: 0, completion: nil)
    }

    
    func commonInit() {
        self.isUserInteractionEnabled = true
        self.backgroundView.isUserInteractionEnabled = true
        
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        print("dismiss button pressed")
        delegate?.didDismiss(proofView: self)
    }
    
}

protocol JustProofViewDelegate {
    func didDismiss(proofView: JustProofView)
}
