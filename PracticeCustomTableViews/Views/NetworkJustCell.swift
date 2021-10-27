//
//  NetworkJustCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/20/21.
//

import UIKit


class NetworkJustCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var respectCountButton: UIButton!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var justLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var respectButton: UIButton!
    var just: Just? {
        didSet {
            print("Just did set called")
            configure()
            setupRespectButton()
            setupImageView()
            setupLongPressGesture()
            fetchToken()
            fetchUserImage()
            
        }
    }
    var currentUserId: String?
    
    var token : String?
    
    @IBOutlet weak var respectLabel: UILabel!
    
    var lineView = UIView()
    
  
    var delegate: NetworkJustCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadows()
        self.respectCountButton.isHidden = true
        self.respectButton.isHidden = true
        self.respectLabel.isHidden = true

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.just = nil
    }
    
    // MARK: - Selectors
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        delegate?.imageTapped(cell: self)
    }
    
    // MARK: - Helper Functions
    
    func fetchToken() {
        guard let just = just else { return }
        UserService.shared.fetchUserToken(uid: just.uid) { token in
            self.token = token
        }
    }
    
    func fetchUserImage() {
        guard let just = self.just else { return }
        UserService.shared.fetchProfileImage(uid: just.uid) { imageURL in
            self.imageView.sd_setImage(with: imageURL) { image, error, cache, url in
                if let error = error {
                    self.imageView.image = UIImage(named: "blank")
                }
            }
        }
    }
    
    func configure() {
        guard let just = just else { return }
        let viewModel = JustViewModel(just: just)
        contentView.isUserInteractionEnabled = true
        justLabel.attributedText = viewModel.userInfoText
        timestampLabel.text = viewModel.timestamp
        
    }
    
    func setupRespectButton() {
        guard let just = just else { return }
        if just.uid == currentUserId {
            self.respectButton.isHidden = true
            self.respectLabel.isHidden = true
            self.respectCountButton.isHidden = false
            setupRespectCountButton()
        } else {
            self.respectButton.isHidden = false
            self.respectLabel.isHidden = false
            self.respectCountButton.isHidden = true
            let tap = UIGestureRecognizer(target: self, action: #selector(labelTapped))
            self.respectLabel.addGestureRecognizer(tap)
            self.respectLabel.isUserInteractionEnabled = true
            let imageName = just.didRespect ? "Fistbump4" : "Fistbump1"
            let blue = UIColor.blue
            let lightGray = UIColor.lightGray
            let labelColor = just.didRespect ? blue : lightGray
            respectButton.setImage(UIImage(named: imageName), for: .normal)
            respectLabel.textColor = labelColor
            respectLabel.text = "Respect"
            self.respectButton.imageView?.clipsToBounds = true
            self.respectButton.imageView?.contentMode = .scaleAspectFit
        }
        
    }
    
    @objc func respectCountTapped() {
        delegate?.respectCountTapped(cell: self)
    }
    
    
    @IBAction func respectButtonTapped(_ sender: UIButton) {
        guard var just = just else { return }
        if just.didRespect == false {
            imageView.animationImages = animatedImages(for: "Fistbump")
            imageView.animationDuration = 0.2
            imageView.animationRepeatCount = 1
            imageView.startAnimating()
            self.respectButton.setImage(UIImage(named: "Fistbump4"), for: .normal)
            delegate?.respectTapped(cell: self)
            self.just?.didRespect.toggle()
        } else if just.didRespect == true {
            self.respectButton.setImage(UIImage(named:"Fistbump1"), for: .normal)
            delegate?.respectTapped(cell: self)
            self.just?.didRespect.toggle()
        }
    }
    
    func setupShadows() {
        layer.borderWidth = 0.0
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.75
        layer.masksToBounds = false //<-
    }
    
    func setupLineView() {
        addSubview(lineView)
        lineView.backgroundColor = .blue
        lineView.anchor(top: self.topAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, width: 2)
        lineView.doGlowAnimation(withColor: .blue, withEffect: .big)
        
    }
    
    @objc func labelTapped() {
        print("Label Tapped")
    }
    
    func setupImageView() {
        let tap = UIGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(tap)
        imageView.layer.cornerRadius = imageView.viewHeight / 2
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
    }
    
    func setupLabels() {
        guard let just = just else { return }
        let title = NSMutableAttributedString(string: "\(just.firstName) \(just.lastName) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: "just \(just.justText)", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        
        justLabel.attributedText = title
        
        
    }
    

    
    @objc func imageTapped() {
        delegate?.imageTapped(cell: self)
        print("Image tapped")
    }
    
    func animatedImages(for name: String) -> [UIImage] {
        var i = 1
        var images = [UIImage]()
        
        while let image = UIImage(named: "\(name)\(i)") {
            images.append(image)
            i += 1
        }
        return images
    }
    
    @objc func didLongPress(sender: UILongPressGestureRecognizer) {
        print("Cell did Long Press")
        if sender.state == UIGestureRecognizer.State.began {
            delegate?.didLongPress(cell: self)
        }
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }
    
    
    func setupRespectCountButton() {
        guard let just = just, let currentUserId = currentUserId else { return }
        let tap = UITapGestureRecognizer(target: self, action: #selector(respectCountTapped))
        self.respectCountButton.addGestureRecognizer(tap)
        self.respectCountButton.isUserInteractionEnabled = true
        if just.uid == currentUserId {
            print("Passed the two guards and if statement")
            JustService.shared.fetchJustRespects(just: just) { respectCount in
                if let respectCount = respectCount {
                    let count = Int(respectCount)
                    switch count {
                    case 1:
                        self.respectCountButton.setTitle("\(count) respect", for: .normal)
                    case _ where count >= 2:
                        self.respectCountButton.setTitle("\(count) respects", for: .normal)
                    default:
                        self.respectCountButton.isHidden = true
                    }
                    
                }
            }

        }
    }
    
    
}

protocol NetworkJustCellDelegate {
    func imageTapped(cell: NetworkJustCell)
    func respectTapped(cell: NetworkJustCell)
    func didLongPress(cell: NetworkJustCell)
    func respectCountTapped(cell: NetworkJustCell)
}
