//
//  PracticeCollectionViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/4/21.
//

import UIKit

private let reuseIdentifier = "Cell"

class PracticeCollectionViewController: UICollectionViewController, UINavigationControllerDelegate, UINavigationBarDelegate {
    
    let dummyData = DummyData()
    var delegate : UINavigationControllerDelegate?
    var delegate2 : UINavigationBarDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes

        // Do any additional setup after loading the view.
    }
    
    func updateViews() {
        self.delegate = self
        self.delegate2 = self
        
    }
    
    
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        print("profile button tapped")
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController")as! ProfileViewController
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        

        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dummyData.usernameArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PracticeCollectionViewCell
        
        cell.networkLabel.text = dummyData.usernameArray[indexPath.item] + "'s Network"
        cell.newJustsLabel.text = dummyData.newJustsArray[indexPath.item]
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.cornerRadius = 4
//        cell.contentView.layer.shadowOpacity = 1
        cell.contentView.layer.shadowRadius = 5
        cell.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        
        
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
