//
//  ViewJustController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/10/21.
//

import Foundation
import UIKit

class ViewJustController: UICollectionViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var just: Just? {
        didSet {
            collectionView.reloadData()
        }
    }
    var user: User?
    var justID: String
    var currentUser: User
    let justNibName = "NetworkJustCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        fetchJust()
    }
    
    // MARK: - Initializer
    
    init(justID: String, user: User?, currentUser: User) {
        self.justID = justID
        self.user = user
        self.currentUser = currentUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    
    func updateViews() {
        collectionView.delegate = self
        self.title = "Just"
        let nib = UINib(nibName: justNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "networkJustCell")
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Firebase Functions
    
    func fetchJust() {
        JustService.shared.fetchSingleJust(justID: justID) { just in
            self.just = just
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "networkJustCell", for: indexPath) as! NetworkJustCell
  
            cell.just = just
            cell.delegate = self
            cell.currentUserId = self.currentUser.uid
        
     
        cell.imageView.isUserInteractionEnabled = true
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ViewJustController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        if let just = just {
            let viewModel = JustViewModel(just: just)
            let height = viewModel.size(forWidth: view.frame.width).height
            return CGSize(width: view.frame.width - 20, height: height + 80)
        }
        
        return CGSize(width: view.frame.width - 20, height: view.frame.height + 80)
    }
}

// MARK: - NetworkJustCellDelegate

extension ViewJustController: NetworkJustCellDelegate {
    func imageTapped(cell: NetworkJustCell) {
        
    }
    
    func respectTapped(cell: NetworkJustCell) {
        
    }
    
    func didLongPress(cell: NetworkJustCell) {
        
    }
    
    func respectCountTapped(cell: NetworkJustCell) {
        
    }
    
    
}
