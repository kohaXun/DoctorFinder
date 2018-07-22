//
//  ComponentModelMock.swift
//  DoctorFinderTests
//
//  Created by Sten Anderßen on 23.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import XCTest
@testable import DoctorFinder

class ComponentModelWithoutTitles: BaseCollectionComponentModel {
    
    override func convertData() {
        super.convertData()
        guard let data = data as? [String] else {
            return
        }
        convertedData?.append(BaseSectionDataModel(with: data))
    }
}

class ComponentModelWithTitles: BaseCollectionComponentModel {
    
    let sectionHeader: String
    let sectionFooter: String
    
    init(with data: [Any?], sectionHeader: String, sectionFooter: String) {
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        super.init(with: data)
    }
    
    override func convertData() {
        super.convertData()
        guard let data = data as? [String] else {
            return
        }
        convertedData?.append(BaseSectionDataModel(with: data, sectionHeaderTitle: sectionHeader, sectionFooterTitle: sectionFooter))
    }
}

class ComponentModelWithSections: BaseCollectionComponentModel {
    
    override func convertData() {
        super.convertData()
        guard let data = data as? [[String]] else {
            return
        }
        for stringArray in data {
            convertedData?.append(BaseSectionDataModel(with: stringArray))
        }
    }
}

class ComponentModelWithTitlesAndMultipleSections: BaseCollectionComponentModel {
    
    let sectionHeader: String
    let sectionFooter: String
    
    init(with data: [Any?], sectionHeader: String, sectionFooter: String) {
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        super.init(with: data)
    }
    
    override func convertData() {
        super.convertData()
        guard let data = data as? [[String]] else {
            return
        }
        for stringArray in data {
            convertedData?.append(BaseSectionDataModel(with: stringArray, sectionHeaderTitle: sectionHeader, sectionFooterTitle: sectionFooter))
        }
    }
}
