//
//  PracticeTableViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/4/21.
//

import UIKit

public enum SimpleAnimationEdge {
  case none
  case top
  case bottom
  case left
  case right
}

class PracticeTableViewController: UITableViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UINavigationBarDelegate {

    
    @IBOutlet var justTableView: UITableView!
    @IBOutlet weak var networkButton: UIBarButtonItem!
    let dummyData = DummyData()
    var selectedUsername: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        setupLongPressGesture()
    }
    
    func updateViews() {
        NotificationCenter.default.addObserver(self, selector: #selector (presentProof(_:)), name: .shouldShowProof, object: nil)
        
        if title != "My Network" {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.justTableView.tableFooterView = UIView()
    }
    
    @objc func grabUsername(_ notification: Notification) {
        self.performSegue(withIdentifier: "showUserProfile", sender: self)
    }
    
    @objc func presentProof(_ notfication: Notification) {
        
    }
    
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            print("handling long press")
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath) as! PracticeTableViewCell
                cell.delegate = self
                cell.didLongPress(sender: gestureRecognizer)
            }
        }
    }
    
    func adjustHeader() {
        let header = self.tableView.headerView(forSection: 1)
        
        header?.backgroundColor = .lightText
    }
    


    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.johnJustArray.count

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PracticeTableViewCell
   
            cell.usernameButton.setTitle(dummyData.larsArray[indexPath.row], for: .normal)
            cell.justLabel.text = dummyData.oldJustArray[indexPath.row]
            cell.delegate = self
            cell.updateViews()
            cell.selectionStyle = .none
//            cell.separatorInset = UIEdgeInsets.zero
//            cell.layoutMargins = UIEdgeInsets.zero
            
            
        if let usernameTitle = cell.usernameButton.titleLabel?.text {
            if usernameTitle == "My Network" {
                cell.respectButton.setImage(nil, for: .normal)
                cell.respectButton.setTitle("4 Respects", for: .normal)
            }
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            let destinationVC = segue.destination as! UserProfileViewController
            print("working")
            
            guard let selectedUsername = self.selectedUsername else {return}
            print(selectedUsername)
            destinationVC.titleString = selectedUsername
            destinationVC.updateViews()
        }
    }


}

extension PracticeTableViewController: PracticeTableViewCellDelegate {
    func didLongPress(cell: PracticeTableViewCell) {
        print("yooooo")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        guard let titleLabel = cell.usernameButton.titleLabel else {return}
        if titleLabel.text != "My Network" {
            let reportAlert = UIAlertController(title: "Report Just", message: "Would you like to report this Just?", preferredStyle: .alert)
            let reportAction = UIAlertAction(title: "Report", style: .default, handler: nil)
            reportAlert.addAction(reportAction)
            reportAlert.addAction(cancelAction)
            self.present(reportAlert, animated: true, completion: nil)
        } else if titleLabel.text == "My Network" {
            let deleteAlert = UIAlertController(title: "Delete Just", message: "Would you like to delete this Just?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: nil)
            deleteAlert.addAction(cancelAction)
            deleteAlert.addAction(deleteAction)
            self.present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    func respectedByTapped(cell: PracticeTableViewCell) {
        self.performSegue(withIdentifier: "respectedBy", sender: self)
    }
    
    func usernameButtonTapped(cell: PracticeTableViewCell) {
        guard let buttonTitle = cell.usernameButton.currentTitle else {return}
        self.selectedUsername = buttonTitle
        self.performSegue(withIdentifier: "showProfile", sender: self)
    }
}

extension UIView {
    @discardableResult func slideIn(from edge: SimpleAnimationEdge = .none,
                                    x: CGFloat = 0,
                                    y: CGFloat = 0,
                                    duration: TimeInterval = 0.4,
                                    delay: TimeInterval = 0,
                                    completion: ((Bool) -> Void)? = nil) -> UIView {
      let offset = offsetFor(edge: edge)
      transform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
      isHidden = false
      UIView.animate(
        withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2,
        options: .curveEaseOut, animations: {
          self.transform = .identity
          self.alpha = 1
        }, completion: completion)
      return self
    }
    
    private func offsetFor(edge: SimpleAnimationEdge) -> CGPoint {
      if let parentSize = self.superview?.frame.size {
        switch edge {
        case .none: return CGPoint.zero
        case .top: return CGPoint(x: 0, y: -frame.maxY)
        case .bottom: return CGPoint(x: 0, y: parentSize.height - frame.minY)
        case .left: return CGPoint(x: -frame.maxX, y: 0)
        case .right: return CGPoint(x: parentSize.width - frame.minX, y: 0)
        }
      }
      return .zero
    }
}
    
extension PracticeTableViewController: JustProofViewDelegate {
    func didDismiss(proofView: JustProofView) {
        self.view.willRemoveSubview(proofView)
    }
}

