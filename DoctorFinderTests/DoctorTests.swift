//
//  DoctorTests.swift
//  DoctorFinderTests
//
//  Created by Sten Anderßen on 22.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import XCTest
@testable import DoctorFinder

class DoctorTests: XCTestCase {
    
    func testInitWithCoder() {
        let id = "123456789"
        let name = "title"
        let address = "address"
        let imagePath = "imagePath"
        
        let jsonString = """
        [{
        "id":"\(id)",
        "name":"\(name)",
        "address":"\(address)",
        "photoId":null,
        "phoneNumber":"123456789"
        },
        {
        "id":"\(id)",
        "name":"\(name)",
        "address":"\(address)",
        "photoId":"\(imagePath)",
        "phoneNumber":"123456789"
        }]
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let doctors = try JSONDecoder().decode([Doctor].self, from: jsonData)
            
            for doctor in doctors {
                XCTAssertNotNil(doctor, "Should not be nil")
                XCTAssertEqual(doctor.id, id, "Should be equal")
                XCTAssertEqual(doctor.name, name, "Should be equal")
                XCTAssertEqual(doctor.address, address, "Should be equal")
            }
            
            XCTAssertNil(doctors[0].imagePath, "Should be nil")
            XCTAssertNotNil(doctors[1].imagePath, "Should not be nil")
        } catch {
            XCTFail()
        }
    }
}
