//
//  RemoveAdsViewController.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/25.
//

import UIKit
import StoreKit

class RemoveAdsViewController: UIViewController {
    
    private let buyButton: UIButton = {
        let buyButton = UIButton(type: .system)
        buyButton.setTitle("Buy", for: .normal)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.backgroundColor = .systemGreen
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        return buyButton
    }()
    
    private var myProduct: SKProduct?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProducts()
        view.backgroundColor = .systemGray6
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(touchUpRestoreButton))
        view.addSubview(buyButton)
        buyButton.addTarget(self, action: #selector(touchUpBuyButton), for: .touchUpInside)
        setupLayout()
    }
    
    func fetchProducts() {
        let productIdentifiers: Set<String> = [""]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    @objc private func touchUpRestoreButton() {
       
    }
    
    @objc private func touchUpBuyButton() {
        guard let myProduct = myProduct else {
            return
        }
        
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: myProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            buyButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            buyButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            buyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25)
        ])
    }
    
}

extension RemoveAdsViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            myProduct = product
            print(product.productIdentifier)
            print(product.price)
            print(product.localizedTitle)
            print(product.localizedDescription)
        }
    }
}

extension RemoveAdsViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased, .restored:
                UserDefaults.standard.setValue(true, forKey: "ads_removed")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            case .failed, .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            }
        }
    }
}
