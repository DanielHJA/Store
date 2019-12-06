//
//  Alert.swift
//  ApplePayTest
//
//  Created by Daniel Hjärtström on 2019-12-06.
//  Copyright © 2019 Daniel Hjärtström. All rights reserved.
//

import UIKit

class Alert {
    
    class func displayDefaultAlert(title: String?, message: String?, presentingViewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        presentingViewController.present(alert, animated: true, completion: nil)
    }
    
}
