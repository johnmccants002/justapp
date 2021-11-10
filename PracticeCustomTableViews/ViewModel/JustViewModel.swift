//
//  JustViewModel.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/24/21.
//

import Foundation
import UIKit


struct JustViewModel {
    let just: Just
    
    var profileImageUrl: URL? {
        return just.profileImageUrl
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        
        let now = Date()
        if formatter.string(from: just.timestamp, to: now) == "0d" {
            return "Today"
        }
        return formatter.string(from: just.timestamp, to: now) ?? "2m"
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: "\(just.firstName) \(just.lastName) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: "\(just.justText)", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        
        if let justImageUrl = just.justImageUrl {
            let text = (" (Photo 🖼)")
            let underlineAttriString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
            let photoRange = (text as NSString).range(of: " (Photo 🖼)")
            underlineAttriString.addAttribute(.foregroundColor, value: UIColor.blue, range: photoRange)
            title.append(NSAttributedString(attributedString: underlineAttriString))
        }
        
        return title
    }
    
    func size(forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = just.justText
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        let size = measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size
    }

}
