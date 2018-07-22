//
//  UIAlertControllerExtension.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 19.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    // MARK: - Location
    
    /// Returns an UIAlertController that should be displayed when the current location could not be determined by the device.
    ///
    /// - Returns: The created alert controller
    static func locationNotAvailableAlert() -> UIAlertController {
        let title = "Location not available"
        let message = "In order to search for a doctor near you we need your current location. Please make sure your device has a GPS signal and try again."
        return singleButtonAlert(with: title, message: message, buttonTitle: "Ok")
    }
    
    /// Returns an UIAlertController that should be displayed when the user turned off location services in the settings app.
    ///
    /// - Returns: The created alert controller
    static func locationServicesDisabledAlert() -> UIAlertController {
        let title = "Location services are turned off"
        let message = "In order to search for a doctor near you we need your current location. Please enable location services in system settings."
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Open System Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return controller
    }
    
    // MARK: - Abstract
    
    /// Returns an UIAlertController with a single button.
    ///
    /// - Parameters:
    ///   - title: The title of the alert controller
    ///   - message: The message of the alert controller
    ///   - buttonTitle: The button title of the button
    ///   - buttonHandler: The handler that should be invocated after the user taps on the button
    /// - Returns: The created alert controller
    static func singleButtonAlert(with title: String, message: String, buttonTitle: String, buttonHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: buttonHandler))
        return controller
    }
    
    /// Returns an UIAlertController with a single "Ok" button for a given error.
    ///
    /// - Parameter error: The error for creating a title and message for the controller
    /// - Returns: The created alert controller
    static func alert(for error: Error) -> UIAlertController {
        guard let error = error as? NetworkError else {
            return alert()
        }
        switch error {
        case .noConnection:
            let title = "No internet connection"
            let message = "It seems your device has no internet connection. Please reconnect and try again."
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            return controller
        default:
            return alert()
        }
    }
    
    /// Returns an UIAlertController with a single "Ok" button and a default error title and message.
    ///
    /// - Returns: The created alert controller
    static func alert() -> UIAlertController {
        let title = "Something went wrong"
        let message = "Please try again. If the error still exists please contact support."
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        return controller
    }
}

