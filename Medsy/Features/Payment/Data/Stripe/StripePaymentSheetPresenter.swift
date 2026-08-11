//
//  StripePaymentSheetPresenter.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import StripePaymentSheet
import UIKit

final class StripePaymentSheetPresenter: PaymentSheetPresentingProtocol {
    private let publishableKey: String

    init(publishableKey: String = Constants.stripePublishableKey) {
        self.publishableKey = publishableKey
    }

    func present(_ request: PaymentSheetPresentationRequest) async -> PaymentSheetPresentationOutcome {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                guard !publishableKey.isEmpty else {
                    continuation.resume(
                        returning: .failed(message: "payment.error.missing_publishable_key".localized)
                    )
                    return
                }
                guard let viewController = UIApplication.shared.paymentPresentationViewController else {
                    continuation.resume(
                        returning: .failed(message: "payment.error.screen_unavailable".localized)
                    )
                    return
                }

                STPAPIClient.shared.publishableKey = publishableKey

                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Medsy"
                configuration.returnURL = "medsy://stripe-redirect"
                configuration.allowsDelayedPaymentMethods = false
                configuration.paymentMethodOrder = ["card"]

                let paymentSheet = PaymentSheet(
                    paymentIntentClientSecret: request.clientSecret,
                    configuration: configuration
                )
                paymentSheet.present(from: viewController) { result in
                    switch result {
                    case .completed:
                        continuation.resume(returning: .completed)
                    case .canceled:
                        continuation.resume(returning: .cancelled)
                    case .failed(let error):
                        continuation.resume(returning: .failed(message: error.localizedDescription))
                    }
                }
            }
        }
    }
}

private extension UIApplication {
    @MainActor
    var paymentPresentationViewController: UIViewController? {
        let keyWindow = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)

        return keyWindow?.rootViewController?.topmostPresentedViewController
    }
}

private extension UIViewController {
    var topmostPresentedViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topmostPresentedViewController
        }
        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.topmostPresentedViewController
        }
        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topmostPresentedViewController
        }
        return self
    }
}
