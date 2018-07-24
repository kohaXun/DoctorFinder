//
//  LoadingView.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 24.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import UIKit

/// The loading view is responsible for showing a spinner while the user has to wait for the app to complete a network task.
class LoadingView: ViewFromXib {
    
    let kFadeAnimationDuration = 0.2
    
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        self.alpha = 0
    }
    
    func start() {
        activityIndicatorView.startAnimating()
        UIView.animate(withDuration: kFadeAnimationDuration) {
            self.alpha = 1
        }
    }
    
    func stop() {
        UIView.animate(withDuration: kFadeAnimationDuration, animations: {
            self.alpha = 0
        }) { _ in
            self.activityIndicatorView.stopAnimating()
        }
    }
}
