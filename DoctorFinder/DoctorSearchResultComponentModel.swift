//
//  DoctorSearchResultComponentModel.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 19.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

/// View model that holds doctor data that is displayed in a collection component controller.
class DoctorSearchResultComponentModel: BaseCollectionComponentModel {
    
    override func convertData() {
        super.convertData()
        guard let data = data as? [Doctor] else {
            return
        }
        let rowData = data.map { doctor in
            return DoctorSearchResultCellModel(name: doctor.name, address: doctor.address, imagePath: doctor.imagePath)
        }
        convertedData?.append(BaseSectionDataModel(with: rowData))
    }
}

