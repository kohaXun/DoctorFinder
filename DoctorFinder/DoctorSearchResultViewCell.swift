//
//  DoctorSearchResultViewCell.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 19.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import UIKit
import AlamofireImage

/// View cell that displays a doctor in a table view.
class DoctorSearchResultViewCell: BaseTableComponentViewCell {
    
    @IBOutlet private weak var doctorImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    
    // MARK: - BaseTableComponentProtocol
    override func updateUI() {
        guard let model = data as? DoctorSearchResultCellModel else {
            return
        }
        
        nameLabel.text = model.name
        addressLabel.text = model.address.replacingOccurrences(of: ", ", with: "\n")
        
        if let imagePath = model.imagePath {
            doctorImageView.af_setImage(withURLRequest: UvitaRouter.image(path: imagePath), placeholderImage: UIImage(named: "PosterPlaceholderImage"))
        }
    }
}

