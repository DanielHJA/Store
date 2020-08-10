//
//  ViewController.swift
//  ApplePayTest
//
//  Created by Daniel Hjärtström on 2019-12-06.
//  Copyright © 2019 Daniel Hjärtström. All rights reserved.
//

import UIKit
import PassKit
import Stripe

class ViewController: UIViewController {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
        
    private var selectedItem: Shoe {
        let index = pickerView.selectedRow(inComponent: 0)
        return shoes[index]
    }
    
    let shoes = [
          Shoe(name: "Nike Air Force 1 High LV8", price: 110.00),
          Shoe(name: "adidas Ultra Boost Clima", price: 139.99),
          Shoe(name: "Jordan Retro 10", price: 190.00),
          Shoe(name: "adidas Originals Prophere", price: 49.99),
          Shoe(name: "New Balance 574 Classic", price: 90.00)
      ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapBuy(_ sender: Any) {
        Store.shared.initializePurchaseWith(item: selectedItem, with: self)
    }
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shoes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shoes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let priceString = String(format: "%.02f", shoes[row].price)
        priceLabel.text = "Price = $\(priceString)"
    }
    
}

extension ViewController: PKPaymentAuthorizationViewControllerDelegate, STPAuthenticationContext {
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
        
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {

        STPAPIClient.shared().createPaymentMethod(with: payment) { (method, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let method = method {
                let clientSecret = "sk_test_UR0O6QZ9uMDSJq5wMW0QxaFg00j0kEi4mg"
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.paymentMethodId = method.stripeId
                
                STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, intent, error) in
                    switch status {
                    case .succeeded:
                        print("Payment success")
                        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    case .canceled:
                        print("Payment was cancelled")
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    case .failed:
                        print("Payment failed")
                        let errors = [STPAPIClient.pkPaymentError(forStripeError: error)].compactMap({ $0 })
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                    @unknown default:
                        break
                    }
                }
                
            }
            
        }
        
            dismiss(animated: true, completion: nil)
//        if let viewController = UIApplication.shared.windows.first?.rootViewController {
//            Alert.displayDefaultAlert(title: "Success", message: "The Apple Pay Transaction was completed successfully", presentingViewController: viewController)
//        }
    }
    
}
