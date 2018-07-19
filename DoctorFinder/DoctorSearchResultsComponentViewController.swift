//
//  DoctorSearchResultsComponentViewController.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 19.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import UIKit

protocol DoctorSearchResultsComponentDelegate: class {
    func componentDidDisplayLastCell(_ component: DoctorSearchResultsComponentViewController)
}

/// Component view controller that handles the displaying of doctors in a table view.
class DoctorSearchResultsComponentViewController: BaseTableComponentViewController {
    
    // MARK: - Variables
    
    weak var delegate: DoctorSearchResultsComponentDelegate?
    
    // MARK: - BaseTableComponentProtocol
    
    override func cellIdentifier(for indexPath: IndexPath) -> String {
        return "DoctorSearchResultViewCell"
    }
}

extension DoctorSearchResultsComponentViewController: UITableViewDelegate, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let section = model?.convertedData?.first, section.rows.count - 1 == indexPath.row else {
            return
        }
        
        delegate?.componentDidDisplayLastCell(self)
    }
}

