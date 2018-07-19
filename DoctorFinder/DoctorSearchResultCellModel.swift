//
//  DoctorSearchResultCellModel.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 19.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import Foundation

/// Cell model that holds doctor data that can be displayed in a doctor cell view.
struct DoctorSearchResultCellModel {
    let name: String
    let address: String
    let imagePath: String?
}
