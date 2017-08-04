//
//  Permission.swift
//  Babies
//
//  Created by phi on 2017.08.04.
//  Copyright © 2017 Stanhope Road. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Contacts
import Photos

enum PermissionType {
    case camera
    case contacts
    case photos
}

enum PermissionStatus {
    case notDetermined
    case restricted
    case denied
    case authorized
}

class Permission {
    func requestPermission(for permission: PermissionType, withSettings shouldShowSettings: Bool, completion: @escaping (Bool) -> Void) {
        var status: PermissionStatus = .notDetermined

        if permission == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                status = .authorized
            case .denied:
                status = .denied
            case .restricted:
                status = .restricted
            default:
                status = .notDetermined
            }
        } else if permission == .contacts {
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized:
                status = .authorized
            case .denied:
                status = .denied
            case .restricted:
                status = .restricted
            default:
                status = .notDetermined
            }
        } else if permission == .photos {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                status = .authorized
            case .denied:
                status = .denied
            case .restricted:
                status = .restricted
            default:
                status = .notDetermined
            }
        }

        switch status {
        case .authorized:
            completion(true)
        case .denied,
             .restricted:
            if shouldShowSettings {
                let title = NSLocalizedString("OPEN_SETTINGS_TITLE", comment: "The title of the alert for opening settings")
                let message = NSLocalizedString("OPEN_SETTINGS_MESSAGE", comment: "The message of the alert for opening settings")
                let settingsButton = NSLocalizedString("OPEN_SETTINGS_BUTTON", comment: "The title of the alert button for opening settings")
                let cancelButton = NSLocalizedString("OPEN_SETTINGS_CANCEL", comment: "The title of the alert but for cancelling settings")

                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

                let settingsAction = UIAlertAction(title: settingsButton, style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.openURL(settingsUrl)
                    }

                    completion(false)
                }
                alertController.addAction(settingsAction)

                let cancelAction = UIAlertAction(title: cancelButton, style: .cancel, handler: { (_) in
                    completion(false)
                })
                alertController.addAction(cancelAction)
                UIApplication.shared.presentViewController(alertController)
            } else {
                completion(false)
            }
        case .notDetermined:
            if permission == .camera {
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else if permission == .contacts {
                CNContactStore().requestAccess(for: .contacts, completionHandler: { (granted, _) in
                    if granted {
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            } else if permission == .photos {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized {
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            }
        }
    }
}

extension UIApplication {
    fileprivate var topViewController: UIViewController? {
        var vc = delegate?.window??.rootViewController
        
        while let presentedVC = vc?.presentedViewController {
            vc = presentedVC
        }
        
        return vc
    }
    
    internal func presentViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        topViewController?.present(viewController, animated: animated, completion: completion)
    }
}
