//
//  DoctorSearchResultComponentModelTests.swift
//  DoctorFinderTests
//
//  Created by Sten Anderßen on 23.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import XCTest
@testable import DoctorFinder

class DoctorSearchResultComponentModelTests: XCTestCase {
    
    func testConvertedData() {
        let doctor1 = Doctor(id: "id", name: "name", address: "address", imagePath: nil)
        let doctor2 = Doctor(id: "id2", name: "name2", address: "address2", imagePath: nil)
        let doctors = [doctor1, doctor2]
        let model = DoctorSearchResultComponentModel(with: doctors)
        
        model.convertData()
        
        guard let data = model.convertedData else {
            XCTFail()
            return
        }
        XCTAssertEqual(data.count, 1, "Should be equal")
        
        guard let rows = data.first?.rows else {
            XCTFail()
            return
        }
        XCTAssertEqual(rows.count, doctors.count, "Should be equal")
        
        guard let cellModel = rows.first as? DoctorSearchResultCellModel else {
            XCTFail()
            return
        }
        XCTAssertEqual(cellModel.name, doctor1.name, "Should be equal")
        XCTAssertEqual(cellModel.address, doctor1.address, "Should be equal")
        
        guard let cellModel2 = rows[1] as? DoctorSearchResultCellModel else {
            XCTFail()
            return
        }
        XCTAssertEqual(cellModel2.name, doctor2.name, "Should be equal")
        XCTAssertEqual(cellModel2.address, doctor2.address, "Should be equal")
    }
    
    func testConvertedDataWrongData() {
        let data = ["test"]
        let model = DoctorSearchResultComponentModel(with: data)
        
        model.convertData()

        guard let convertedData = model.convertedData else {
            XCTFail()
            return
        }
        XCTAssertEqual(convertedData.count, 0, "Should be empty")
    }
    
}
