//
//  ComponentModelTests.swift
//  DoctorFinderTests
//
//  Created by Sten Anderßen on 23.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import XCTest
@testable import DoctorFinder

class ComponentModelTests: XCTestCase {
    
    func testInit() {
        let testData = ["test", "test2", "test3"]
        let model = BaseCollectionComponentModel(with: testData)
        guard let data = model.data as? [String], let convertedData = model.convertedData else {
            XCTFail()
            return
        }
        XCTAssertEqual(data, testData, "Should be equal")
        XCTAssertEqual(convertedData.count, 0, "Should be empty array")
    }
    
    func testConvertData() {
        let data = ["test", "test2", "test3"]
        let modelMock = ComponentModelWithoutTitles(with: data)
        
        guard let converted = modelMock.convertedData else {
            XCTFail()
            return
        }
        XCTAssertTrue(converted.count == 1, "Shoud have exactly one section")
        
        guard let section = converted.first, let rows = section.rows as? [String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(rows, data, "Should be equal")
        XCTAssertNil(section.sectionTitle, "Should be nil")
        XCTAssertNil(section.sectionFooterTitle, "Should be nil")
    }
    
    func testConvertDataWithSectionTitles() {
        let data = ["test", "test2", "test3"]
        let sectionHeader = "test"
        let sectionFooter = "test"
        let modelMock = ComponentModelWithTitles(with: data, sectionHeader: sectionHeader, sectionFooter: sectionFooter)
        
        guard let converted = modelMock.convertedData else {
            XCTFail()
            return
        }
        XCTAssertTrue(converted.count == 1, "Shoud have exactly one section")
        
        guard let section = converted.first, let rows = section.rows as? [String], let sectionTitle = section.sectionTitle, let sectionFooterTitle = section.sectionFooterTitle else {
            XCTFail()
            return
        }
        XCTAssertEqual(rows, data, "Should be equal")
        XCTAssertEqual(sectionTitle, sectionHeader, "Should be equal")
        XCTAssertEqual(sectionFooterTitle, sectionFooter, "Should be equal")
    }
    
    func testNumberOfSections() {
        let data = ["test", "test2", "test3"]
        let modelMock = ComponentModelWithoutTitles(with: data)
        XCTAssertEqual(modelMock.numberOfSections(), 1, "Should be equal")
    }
    
    func testNumberOfSectionsWithMultipleSections() {
        let data = [["test", "test2", "test3"], ["test4"]]
        let modelMock = ComponentModelWithSections(with: data)
        XCTAssertEqual(modelMock.numberOfSections(), data.count, "Should be equal")
    }
    
    func testNumberOfItemsInSection() {
        let section1 = ["test", "test2", "test3"]
        let section2 = ["test4"]
        let data = [section1, section2]
        let modelMock = ComponentModelWithSections(with: data)
        XCTAssertEqual(modelMock.numberOfItemsInSection(section: 0), section1.count, "Should be equal")
        XCTAssertEqual(modelMock.numberOfItemsInSection(section: 1), section2.count, "Should be equal")
        XCTAssertEqual(modelMock.numberOfItemsInSection(section: 2), 0, "Should be empty")
    }
    
    func testGetCellData() {
        let row1 = "test"
        let row2 = "test2"
        let row3 = "test3"
        let row4 = "test4"
        let section1 = [row1, row2, row3]
        let section2 = [row4]
        let data = [section1, section2]
        let modelMock = ComponentModelWithSections(with: data)
        
        guard let rowData1 = modelMock.getCellData(forIndexPath: IndexPath(row: 2, section: 0)) as? String else {
            XCTFail()
            return
        }
        XCTAssertEqual(rowData1, row3, "Should be equal")
        
        guard let rowData2 = modelMock.getCellData(forIndexPath: IndexPath(row: 0, section: 1)) as? String else {
            XCTFail()
            return
        }
        XCTAssertEqual(rowData2, row4, "Should be equal")
        
        let rowData3 = modelMock.getCellData(forIndexPath: IndexPath(row: section1.count, section: 0))
        XCTAssertNil(rowData3, "Should be nil")
        
        let rowData4 = modelMock.getCellData(forIndexPath: IndexPath(row: 0, section: data.count))
        XCTAssertNil(rowData4, "Should be nil")
    }
    
    func testGetSectionHeaderTitleAndFooter() {
        let section1 = ["test", "test2", "test3"]
        let section2 = ["test4"]
        let data = [section1, section2]
        let sectionHeader = "test"
        let sectionFooter = "test"
        let modelMock = ComponentModelWithTitlesAndMultipleSections(with: data, sectionHeader: sectionHeader, sectionFooter: sectionFooter)
        let headerTitle = modelMock.getTitleForHeader(inSection: 0)
        XCTAssertEqual(headerTitle, sectionHeader, "Should be equal")
        let footerTitle = modelMock.getTitleForFooter(inSection: 0)
        XCTAssertEqual(footerTitle, sectionFooter, "Should be equal")
        
        XCTAssertNil(modelMock.getTitleForHeader(inSection: data.count), "Should be nil")
        XCTAssertNil(modelMock.getTitleForFooter(inSection: data.count), "Should be nil")
    }
}
