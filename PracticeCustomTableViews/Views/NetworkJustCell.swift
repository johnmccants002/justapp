//
//  NetworkJustCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/20/21.
//

import UIKit


class NetworkJustCell: UICollectionViewCell, UIGestureRecognizerDelegate {
     
    // MARK: - Properties
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var moreJustsButton: UIButton!
    @IBOutlet weak var respectCountButton: UIButton!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var justLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var respectButton: UIButton!
    
    var section: Int?
    var row: Int?
    var justImageView = UIImageView()
    var just: Just? {
        didSet {
            configure()
            setupRespectButton()
            setupImageView()
            setupLongPressGesture()
            fetchUserImage()
            setupLabelTapJustImageView()
            setupFireLabel()
        }
    }
    var currentUser: User? {
        didSet {
            setupRespectCountButton()
        }
    }
    
    var nameButton = UIButton()
    var currentUserId: String?
    var token : String?
    @IBOutlet weak var respectLabel: UILabel!
    var lineView = UIView()
    var delegate: NetworkJustCellDelegate?

    
    var fireLabel: UILabel = {
        let label = UILabel()
        label.text = "🔥"
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycles
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadows()
        overrideUserInterfaceStyle = .light

    }
    
    override func layoutSubviews() {
        self.setupRespectButton()
        self.addSubview(justImageView)
        justImageView.isHidden = true
        justImageView.centerX(inView: self)
        justImageView.centerY(inView: self)
        justImageView.setDimensions(width: 20, height: 20)
//        self.nameButton.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
//        self.addSubview(nameButton)
//        self.bringSubviewToFront(nameButton)
//        self.nameButton.setDimensions(width: , height: self.imageView.viewHeight)
//        self.nameButton.anchor(top: justLabel.topAnchor, left: imageView.rightAnchor)
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.just = nil
    }
    
    // MARK: - Firebase Functions
    
    func fetchUserImage() {
        guard let just = self.just else { return }
        UserService.shared.fetchProfileImage(uid: just.uid) { imageURL in
                if let imageURL = imageURL {
                    self.imageView.sd_setImage(with: imageURL) { image, error, cache, url in
                    }
            } else {
                self.imageView.image = UIImage(named: "blank")
            }
        }
    }
    
    func setupFireLabel() {
        if let just = just {
            if just.userOnFire == true {
                self.addSubview(fireLabel)
                fireLabel.text = "🔥"
                fireLabel.font = UIFont(name: "HelveticaNeue", size: 9)
                fireLabel.anchor(top: imageView.topAnchor, left: imageView.rightAnchor, paddingTop: -2, paddingLeft: -20, width: 25, height: 15)
                
                UserService.shared.fetchFireImage(uid: just.uid) { url in
                    self.imageView.sd_setImage(with: url) { image, err, cache, url in
                    }
                }
            }
        }
        
    }
    
    func setupRespectCountButton() {
        guard let just = just, let currentUserId = currentUserId else { return }
        let tap = UITapGestureRecognizer(target: self, action: #selector(respectCountTapped))
        self.respectCountButton.addGestureRecognizer(tap)
        self.respectCountButton.isUserInteractionEnabled = true
        self.respectCountButton.setTitleColor(.black, for: .normal)
        if just.uid == currentUserId {
            print("Passed the two guards and if statement")
                let count = just.respects
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
    
    func fetchToken() {
        guard let just = just else { return }
        UserService.shared.fetchUserToken(uid: just.uid) { token in
            self.token = token
            self.just?.token = token
        }
    }
    
    // MARK: - Helper Functions
    
    func configure() {
        guard let just = just else { return }
        let viewModel = JustViewModel(just: just)
        contentView.isUserInteractionEnabled = true
        justLabel.attributedText = viewModel.userInfoText
        
        if let dateString = just.dateString {
            timestampLabel.text = dateString
        } else {
            timestampLabel.text = viewModel.timestamp
        }
        
        
        if let justImageUrl = just.justImageUrl {
            justImageView.sd_setImage(with: justImageUrl) { img, err, cache, url in
                self.justImageView.setupImageViewer(options: [.theme(.dark)], from: nil)
            }
        } else {
            self.justImageView.image = UIImage(named: "blank")
        }
        
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
            let black = UIColor.black
            let lightGray = UIColor.lightGray
            let labelColor = just.didRespect ? black : lightGray
            respectButton.setImage(UIImage(named: imageName), for: .normal)
            respectLabel.textColor = labelColor
            respectLabel.text = "Respect"
            self.respectButton.imageView?.clipsToBounds = true
            self.respectButton.imageView?.contentMode = .scaleAspectFit
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
    
    func setupNameButton() {
        self.nameButton.addTarget(self, action: #selector(tapLabel(gesture:)), for: .touchUpInside)
        self.nameButton.setDimensions(width: self.justLabel.viewWidth, height: self.justLabel.viewHeight)
       
        self.bringSubviewToFront(nameButton)
    }
    
    func setupLabelTapJustImageView() {
        guard let just = just else { return }
            let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
            justLabel.isUserInteractionEnabled = true
            self.contentView.isUserInteractionEnabled = true
            
            justLabel.addGestureRecognizer(tapAction)
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
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
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
    
    
    // MARK: - Selectors
    
    @IBAction func moreJustsButtonTapped(_ sender: UIButton) {
        delegate?.moreButtonTapped(cell: self)
    }
    
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        delegate?.imageTapped(cell: self)
    }
    
    @IBAction func respectButtonTapped(_ sender: UIButton) {
        guard var just = just else { return }
        print("respect button tapped passed guard.")
        if just.didRespect == false {
            self.respectButton.imageView!.animationImages = animatedImages(for: "Fistbump")
            self.respectButton.imageView!.animationDuration = 0.2
            self.respectButton.imageView!.animationRepeatCount = 1
            self.respectButton.imageView!.startAnimating()
            self.respectButton.setImage(UIImage(named: "Fistbump4"), for: .normal)
            self.respectLabel.textColor = .black
            delegate?.respectTapped(cell: self)
            self.just?.didRespect.toggle()
            
        } else if just.didRespect == true {
            print("just didRespect true")
            self.respectButton.setImage(UIImage(named:"Fistbump1"), for: .normal)
            self.respectLabel.textColor = .lightGray
            delegate?.respectTapped(cell: self)
            self.just?.didRespect.toggle()
        }
    }
    
    @objc func respectCountTapped() {
        delegate?.respectCountTapped(cell: self)
    }
    
    @objc func labelTapped() {
        self.respectButtonTapped(respectButton)
    }

    @objc func imageTapped() {
        delegate?.imageTapped(cell: self)
    }
        
    @objc func didLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            delegate?.didLongPress(cell: self)
        }
    }
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        guard let postText = justLabel.text else { return }
        guard let just = just else { return }
        if gesture.didTapAttributedTextInLabel(label: justLabel, targetText: "\(just.firstName) \(just.lastName)") {
            delegate?.imageTapped(cell: self)
        } else if gesture.didTapAttributedTextInLabel(label: justLabel, targetText: " (Photo 🖼)") {
                self.justImageView.showImageViewerWithoutTap(iv: self.justImageView)
                print(" Photo 🖼")
        } else if let justImageUrl = just.justImageUrl {
                self.justImageView.showImageViewerWithoutTap(iv: self.justImageView)
            }

}
}

// MARK: - NetworkJustCellDelegate

protocol NetworkJustCellDelegate {
    func imageTapped(cell: NetworkJustCell)
    func respectTapped(cell: NetworkJustCell)
    func didLongPress(cell: NetworkJustCell)
    func respectCountTapped(cell: NetworkJustCell)
    func moreButtonTapped(cell: NetworkJustCell)
    
}
