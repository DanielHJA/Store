//
//  Store.swift
//  ApplePayTest
//
//  Created by Daniel Hjärtström on 2019-12-06.
//  Copyright © 2019 Daniel Hjärtström. All rights reserved.
//

import UIKit
import PassKit
import Stripe

class Store: NSObject {
    static let shared: Store = Store()
    private override init() {}
    
    let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
    
    private var paymentOptions: String {
        return (paymentNetworks.map { $0.rawValue }).joined(separator: ", ")
    }

    func createPaymentItem(for shoe: Shoe) -> PKPaymentSummaryItem {
        return PKPaymentSummaryItem(label: shoe.name, amount: NSDecimalNumber(value: shoe.price), type: .final)
    }
    
    func canMakeMayments() -> Bool {
        if PKPaymentAuthorizationController.canMakePayments(usingNetworks: paymentNetworks) {
            print("Can make payments")
            return true
        } else {
            print("Unable to make payments using: \(paymentOptions)")
            return false
        }
    }
    
    func configurePaymentRequest(_ paymentSummaryItems: [PKPaymentSummaryItem]) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.merchantIdentifier = "merchant.\(Bundle.main.bundleIdentifier!)"
        request.merchantCapabilities = [.capability3DS]
        request.supportedNetworks = paymentNetworks
        request.paymentSummaryItems = paymentSummaryItems
        return request
    }
    
    func presentPKPaymentController(from viewController: UIViewController, with request: PKPaymentRequest) {
        guard let paymentAuthorizationController = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            print("Unable to create PKPaymentAuthorizationViewController")
            return
        }
        
        paymentAuthorizationController.delegate = viewController as? PKPaymentAuthorizationViewControllerDelegate
        viewController.present(paymentAuthorizationController, animated: true, completion: nil)
    }
    
    func initializePurchaseWith(item: Shoe, with presentingViewController: UIViewController) {
        let summaryItem = Store.shared.createPaymentItem(for: item)
        
        if Store.shared.canMakeMayments() {
            let paymentRequest = Store.shared.configurePaymentRequest([summaryItem])
            Store.shared.presentPKPaymentController(from: presentingViewController, with: paymentRequest)
        } else {
            Alert.displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay Transactions", presentingViewController: presentingViewController)
        }
    }
    
}

