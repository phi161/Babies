//
//  UIViewController+Utilities.swift
//  Babies
//
//  Created by phi on 01/06/2017.
//  Copyright © 2017 Stanhope Road. All rights reserved.
//

import UIKit

extension UIViewController {
    func promptToOpenSettings(withTitle title: String, message: String, settingsButton: String, cancelButton: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: settingsButton, style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: cancelButton, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
