//
//  RemoveAdsViewController.swift
//  BigTimer
//
//  Created by 임성민 on 2021/07/25.
//

import UIKit
import StoreKit

class RemoveAdsViewController: UIViewController {
    private let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.largeTitle)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    private let priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        return priceLabel
    }()
    private let buyButton: UIButton = {
        let buyButton = UIButton(type: .system)
        buyButton.setTitle("Remove Ads", for: .normal)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.backgroundColor = .systemGreen
        buyButton.layer.cornerRadius = 15
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        return buyButton
    }()
    private var myProduct: SKProduct?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProducts()
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(priceLabel)
        view.addSubview(stackView)
        view.backgroundColor = .systemGray6
        title = "Remove Ads"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(touchUpRestoreButton))
        view.addSubview(buyButton)
        buyButton.addTarget(self, action: #selector(touchUpBuyButton), for: .touchUpInside)
        setupLayout()
    }
    
    func fetchProducts() {
        let productIdentifiers: Set<String> = [Secrets.productIdentifierForIAP]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    @objc private func touchUpRestoreButton() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
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
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 25),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -25),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buyButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 25),
            buyButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -25),
            buyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            buyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func showAlert(message: String, okActionHandler: (() -> Void)?) {
        let alert: UIAlertController = UIAlertController(title: "BbigTimer", message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            okActionHandler?()
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension RemoveAdsViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            myProduct = product
            DispatchQueue.main.async {
                self.titleLabel.text = product.localizedTitle
                self.descriptionLabel.text = product.localizedDescription
                self.priceLabel.text = product.localizedPrice
            }
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
                NotificationCenter.default.post(name: .iapServicePurchaseNotification, object: nil)
                showAlert(message: "Successs To Remove Ads", okActionHandler: nil)
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
    
    func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) {
        showAlert(message: restoreCompletedTransactionsFailedWithError.localizedDescription, okActionHandler: nil)
    }
}
