//
//  AuthenticationHandler.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 18.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import Foundation
import Alamofire

/// The AuthenticationHandler is a middleware responsible for retrieving a valid session when the network request received an authentication challenge. After successfully retrieving a valid session the initial request gets exectured again.
class AuthenticationHandler {
    
    private let username: String
    private let password: String
    private let lock = NSLock()
    
    private var accessToken: String?
    private var refreshToken: String?
    private var isRefreshing = false
    private var requestsToRetry = [RequestRetryCompletion]()

    init(with username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    /// This method loads and sets a new access token and the refresh token.
    ///
    /// - Parameters:
    ///   - manager: The session manager responsible for the network request
    ///   - completion: The completion block that gets executed after the network request did finish
    private func refreshTokens(with manager: SessionManager, completion: @escaping (_ succeeded: Bool) -> Void) {
        isRefreshing = true
        manager.request(UvitaRouter.oauth(username: username, password: password, refreshToken: refreshToken)).responseJSON { [weak self] response in
            guard let strongSelf = self else {
                return
            }
            if  let json = response.result.value as? [String: Any],
                let accessToken = json["access_token"] as? String,
                let refreshToken = json["refresh_token"] as? String {
                    strongSelf.accessToken = accessToken
                    strongSelf.refreshToken = refreshToken
                    completion(true)
            } else {
                completion(false)
            }
        
            strongSelf.isRefreshing = false
        }
    }
}

extension AuthenticationHandler: RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let resource = urlRequest.url?.pathComponents[1] {
            
            // Use Basic Auth authentication for retrieving a new access token.
            if resource == "oauth" {
                var urlRequest = urlRequest
                urlRequest.setValue("Basic aXBob25lOmlwaG9uZXdpbGxub3RiZXRoZXJlYW55bW9yZQ==", forHTTPHeaderField: "Authorization")
                return urlRequest
            }
            
            // Otherwise use the Access Token for every request that is called on the resource "api"
            else if resource == "api", let accessToken = accessToken {
                var urlRequest = urlRequest
                urlRequest.setValue("Bearer "+accessToken, forHTTPHeaderField: "Authorization")
                return urlRequest
            }
        }
        return urlRequest
    }
}

extension AuthenticationHandler: RequestRetrier {
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        // Mutex for the current thread so every other request on this thread has to wait
        lock.lock()
        defer {
            lock.unlock()
        }
        
        // At the moment we only want to retry the request when we received an authentication challenge
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(false, 0.0)
            return
        }
        
        // Collect all simultaneously called requests from all threads
        requestsToRetry.append(completion)

        // Further down we start the authentication process by trying to load a new access and refresh token. This should only be called from one single thread one at a time.
        if isRefreshing {
            return
        }
        
        refreshTokens(with: manager) { [weak self] succeeded in
            guard let strongSelf = self else {
                return
            }
            // Another mutex
            strongSelf.lock.lock()
            defer {
                strongSelf.lock.unlock()
            }
            // Retry every request that was trying to access the API and received an authentication challenge
            strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
            strongSelf.requestsToRetry.removeAll()
        }
    }
}
