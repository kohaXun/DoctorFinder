//
//  UvitaRouter.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 18.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import Alamofire

/// Router class that creates url requests for the Uvita API.
enum UvitaRouter: URLRequestConvertible {
    
    case oauth(username: String, password: String, refreshToken: String?)
    case search(kind: UvitaSearchKind, query: String, latidude: String, longitude: String, lastKey: String?)
    case image(path: String)
    
    internal enum UvitaSearchKind: String {
        case doctors
    }
    
    private var baseUrlString: String {
        return "https://api.uvita.eu/"
    }
    
    private var method: HTTPMethod {
        switch self {
        case .oauth:
            return .post
        case .search, .image:
            return .get
        }
    }
    
    private var path: String {
        switch self {
        case .oauth:
            return "oauth/token"
        case .search(let kind, _, _, _, _):
            return "api/users/me/"+kind.rawValue
        case .image(let path):
            return "api/users/me/files/"+path
        }
    }
    
    private var parameters: [String: String]? {
        switch self {
        case .oauth(let username, let password, let refreshToken):
            if let refreshToken = refreshToken {
                return ["grant_type": "refresh_token", "refresh_token": refreshToken]
            } else {
                return ["grant_type": "password", "username": username, "password": password]
            }
        case .search(_,let query, let latitude, let longitude, let lastKey):
            var parameters = ["search": query, "lat" : latitude, "lng": longitude]
            if let lastKey = lastKey {
                parameters["lastKey"] = lastKey
            }
            return parameters
        default:
            return nil
        }
    }
    
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseUrlString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest
    }
}
