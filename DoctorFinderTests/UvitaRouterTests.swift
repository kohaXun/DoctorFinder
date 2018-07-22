//
//  UvitaRouterTests.swift
//  DoctorFinderTests
//
//  Created by Sten Anderßen on 22.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import XCTest
import CoreLocation
@testable import DoctorFinder

class UvitaRouterTests: XCTestCase {
    
    func testOAuthWithoutRefreshTokenURLRequest() {
        // Example: https://api.uvita.eu/oauth/token?grant_type=password&username=ausername&password=apassword
        
        let username = "ausername"
        let password = "apassword"
        let parameters = [
            "username": username,
            "password": password,
            "grant_type": "password"
        ]
        let httpMethod = "POST"
        let host = "api.uvita.eu"
        let path = "/oauth/token"
        do {
            let request = try UvitaRouter.oauth(username: username, password: password, refreshToken: nil).asURLRequest()

            guard let url = request.url, let urlHost = url.host else {
                XCTFail()
                return
            }
            XCTAssertEqual(urlHost, host, "Shoud be equal")
            XCTAssertEqual(url.path, path, "Shoud be equal")
            XCTAssertEqual(request.httpMethod, httpMethod, "Shoud be equal")

            guard let httpBody = request.httpBody,
                  let httpBodyString = String(bytes: httpBody, encoding: .utf8) else {
                    XCTFail()
                    return
            }
            
            let queryItemsArray = httpBodyString.components(separatedBy: "&")
            let queryItems = queryItemsArray.reduce([String: String]()) { (dictionary, query) -> [String: String] in
                var dictionary = dictionary
                let keyValue = query.components(separatedBy: "=")
                dictionary[keyValue[0]] = keyValue[1]
                return dictionary
            }
            XCTAssertEqual(queryItems, parameters, "Should be equal")
        } catch {
            XCTFail()
        }
    }
    
    func testOAuthWithRefreshTokenURLRequest() {
        // Example: https://api.uvita.eu/oauth/token?grant_type=refresh_token&refresh_token=aRefreshToken
        
        let username = "ausername"
        let password = "apassword"
        let refreshToken = "aRefreshToken"
        let parameters = [
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]
        let httpMethod = "POST"
        let host = "api.uvita.eu"
        let path = "/oauth/token"
        do {
            let request = try UvitaRouter.oauth(username: username, password: password, refreshToken: refreshToken).asURLRequest()
            
            guard let url = request.url, let urlHost = url.host else {
                XCTFail()
                return
            }
            XCTAssertEqual(urlHost, host, "Shoud be equal")
            XCTAssertEqual(url.path, path, "Shoud be equal")
            XCTAssertEqual(request.httpMethod, httpMethod, "Shoud be equal")
            
            guard let httpBody = request.httpBody,
                let httpBodyString = String(bytes: httpBody, encoding: .utf8) else {
                    XCTFail()
                    return
            }
            
            let queryItemsArray = httpBodyString.components(separatedBy: "&")
            let queryItems = queryItemsArray.reduce([String: String]()) { (dictionary, query) -> [String: String] in
                var dictionary = dictionary
                let keyValue = query.components(separatedBy: "=")
                dictionary[keyValue[0]] = keyValue[1]
                return dictionary
            }
            XCTAssertEqual(queryItems, parameters, "Should be equal")
        } catch {
            XCTFail()
        }
    }
    
    func testSearchWithoutLastKeyURLRequest() {
        // Example: https://api.uvita.eu/api/users/me/doctors?lat=52.534709&lng=13.3976972&sort=distance&search=aSearch
        
        let search = "aSearch"
        let location = CLLocation(latitude: 52.534709, longitude: 13.3976972)
        let parameters = [
            "search": search,
            "sort": "distance",
            "lat": String(location.coordinate.latitude),
            "lng": String(location.coordinate.longitude)
        ]
        let httpMethod = "GET"
        let host = "api.uvita.eu"
        let path = "/api/users/me/doctors"
        
        do {
            let request = try UvitaRouter.search(kind: .doctors, query: search, location: location, lastKey: nil).asURLRequest()
            
            guard let url = request.url, let urlHost = url.host else {
                XCTFail()
                return
            }
            XCTAssertEqual(urlHost, host, "Shoud be equal")
            XCTAssertEqual(url.path, path, "Shoud be equal")
            XCTAssertEqual(request.httpMethod, httpMethod, "Shoud be equal")

            guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let queryItems = urlComponents.queryItems else {
                    XCTFail()
                    return
            }
            
            XCTAssertEqual(queryItems.count, parameters.count, "Should be equal")
            
            for queryItem in queryItems {
                guard parameters.contains (where: { (key, value) -> Bool in
                    key == queryItem.name && value == queryItem.value!
                }) else {
                    XCTFail()
                    return
                }
            }
        } catch {
            XCTFail()
        }
    }
    
    func testSearchWithLastKeyURLRequest() {
        // Example: https://api.uvita.eu/api/users/me/doctors?lat=52.534709&lng=13.3976972&sort=distance&search=aSearch&lastKey=aLastKey
        
        let search = "aSearch"
        let location = CLLocation(latitude: 52.534709, longitude: 13.3976972)
        let lastKey = "aLastKey"
        let parameters = [
            "search": search,
            "sort": "distance",
            "lat": String(location.coordinate.latitude),
            "lng": String(location.coordinate.longitude),
            "lastKey": lastKey
        ]
        let httpMethod = "GET"
        let host = "api.uvita.eu"
        let path = "/api/users/me/doctors"
        
        do {
            let request = try UvitaRouter.search(kind: .doctors, query: search, location: location, lastKey: lastKey).asURLRequest()
            
            guard let url = request.url, let urlHost = url.host else {
                XCTFail()
                return
            }
            XCTAssertEqual(urlHost, host, "Shoud be equal")
            XCTAssertEqual(url.path, path, "Shoud be equal")
            XCTAssertEqual(request.httpMethod, httpMethod, "Shoud be equal")
            
            guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let queryItems = urlComponents.queryItems else {
                    XCTFail()
                    return
            }
            
            XCTAssertEqual(queryItems.count, parameters.count, "Should be equal")
            
            for queryItem in queryItems {
                guard parameters.contains (where: { (key, value) -> Bool in
                    key == queryItem.name && value == queryItem.value!
                }) else {
                    XCTFail()
                    return
                }
            }
        } catch {
            XCTFail()
        }
    }
    
    func testImageAsURLRequest() {
        // Example: https://api.uvita.eu/api/users/me/files/aImagePath
        
        let imagePath = "aImagePath"
        let httpMethod = "GET"
        let host = "api.uvita.eu"
        let path = "/api/users/me/files/"+imagePath
        
        do {
            let request = try UvitaRouter.image(path: imagePath).asURLRequest()
            
            guard let url = request.url, let urlHost = url.host else {
                XCTFail()
                return
            }
            XCTAssertEqual(urlHost, host, "Shoud be equal")
            XCTAssertEqual(url.path, path, "Shoud be equal")
            XCTAssertEqual(request.httpMethod, httpMethod, "Shoud be equal")
        } catch {
            XCTFail()
        }
    }
}
