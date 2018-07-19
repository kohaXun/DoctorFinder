//
//  BaseSectionDataModel.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 19.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import Foundation

/// View model class that wraps data in section and rows that can be displayed in a collection view.
class BaseSectionDataModel {
    let rows: [Any]
    var sectionTitle: String?
    var sectionFooterTitle: String?
    
    init(with rowData: [Any], sectionHeaderTitle: String? = nil, sectionFooterTitle: String? = nil) {
        self.rows = rowData
        self.sectionTitle = sectionHeaderTitle
        self.sectionFooterTitle = sectionFooterTitle
    }
}
