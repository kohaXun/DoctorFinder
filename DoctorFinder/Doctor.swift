//
//  Doctor.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 19.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import Foundation

/// Model class that holds data for a doctor.
struct Doctor {
    let id: Int
    let name: String
    let address: String
    let imagePath: String?
}

extension Doctor: Decodable {
    enum DoctorCodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case address = "address"
        case imagePath = "photoId"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DoctorCodingKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let name: String = try container.decode(String.self, forKey: .name)
        let address: String = try container.decode(String.self, forKey: .address)
        let imagePath: String? = try? container.decode(String.self, forKey: .imagePath)
        
        self.init(id: id, name: name, address: address, imagePath: imagePath)
    }
}

struct DoctorResult: Decodable {
    let doctors: [Doctor]
}
