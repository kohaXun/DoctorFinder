//
//  NetworkManager.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 17.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import CoreLocation
import AlamofireNetworkActivityIndicator

enum NetworkError: Error {
    case badRequest
    case internalError
    case invalidResponse
    case noConnection
    case serverError
    case network(error: Error)
    
    init(_ error: Error) {
        let error = error as NSError
        
        switch error.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorInternationalRoamingOff, NSURLErrorDataNotAllowed, NSURLErrorNetworkConnectionLost:
            self = .noConnection
        case NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed, NSURLErrorCannotConnectToHost, NSURLErrorResourceUnavailable, NSURLErrorBackgroundSessionWasDisconnected, NSURLErrorCannotLoadFromNetwork:
            if NetworkManager.shared.isNetworkReachable {
                self = .serverError
            } else {
                self = .noConnection
            }
        default:
            self = .network(error: error)
        }
    }
}

/// Manager class that is responsible for any network request a view needs for displaying data from an API.
class NetworkManager {
    
    static let shared = NetworkManager()
    let session: SessionManager
    
    /// Returns network reachability as a boolean.
    var isNetworkReachable: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    private init() {
        // Create default url configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        session = SessionManager(configuration: configuration)
        
        // Use a middleware to handle any authentication errors from the API
        let authenticationHandler = AuthenticationHandler(with: "ioschallenge@uvita.eu", password: "shouldnotbetoohard")
        session.adapter = authenticationHandler
        session.retrier = authenticationHandler
        
        let imageDownloader = ImageDownloader.default
        let imageDownloaderSession = imageDownloader.sessionManager
        imageDownloaderSession.adapter = authenticationHandler
        imageDownloaderSession.retrier = authenticationHandler
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
    }
    
    func searchDoctors(for searchString: String, near location: CLLocation, lastKey: String? = nil, onSuccess: @escaping ([Doctor], String?) -> Void, onFailure: @escaping (NetworkError) -> Void) throws -> DataRequest {
        return session.request(UvitaRouter.search(kind: .doctors, query: searchString, location: location, lastKey: lastKey))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    do {
                        guard let json = response.data else {
                            onFailure(.internalError)
                            return
                        }
                        let result = try JSONDecoder().decode(DoctorResult.self, from: json)
                        onSuccess(result.doctors, result.lastKey)
                    } catch {
                        onFailure(.invalidResponse)
                    }
                case .failure(let error):
                    onFailure(NetworkError(error))
                }
        }
    }
}
