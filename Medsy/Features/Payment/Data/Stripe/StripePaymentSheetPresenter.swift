//
//  StripePaymentSheetPresenter.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import StripePaymentSheet
import StripePaymentsUI
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

                let cardPaymentViewController = CardPaymentViewController(
                    clientSecret: request.clientSecret
                ) { outcome in
                    continuation.resume(returning: outcome)
                }
                let navigationController = UINavigationController(
                    rootViewController: cardPaymentViewController
                )
                navigationController.modalPresentationStyle = .fullScreen
                viewController.present(navigationController, animated: true)
            }
        }
    }
}

@MainActor
private final class CardPaymentViewController: UIViewController {
    private let clientSecret: String
    private let completion: (PaymentSheetPresentationOutcome) -> Void
    private var didFinish = false

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .interactive
        view.alwaysBounceVertical = true
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.text = "payment.card.title".localized
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.text = "payment.card.subtitle".localized
        return label
    }()

    private lazy var cardFormView: STPCardFormView = {
        let view = STPCardFormView(style: .standard)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.semanticContentAttribute = .forceLeftToRight
        view.delegate = self
        view.accessibilityLabel = "payment.card.details".localized
        return view
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var payButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "payment.card.pay".localized
        configuration.baseBackgroundColor = UIColor(
            red: 0 / 255,
            green: 155 / 255,
            blue: 90 / 255,
            alpha: 1
        )
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer {
            var attributes = $0
            attributes.font = .preferredFont(forTextStyle: .headline)
            return attributes
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()

    init(
        clientSecret: String,
        completion: @escaping (PaymentSheetPresentationOutcome) -> Void
    ) {
        self.clientSecret = clientSecret
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
    }

    func authenticationPresentingViewController() -> UIViewController {
        topmostPresentedViewController
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "payment.card.navigation_title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "payment.card.cancel".localized,
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
    }

    private func configureLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, subtitleLabel, cardFormView, errorLabel, payButton].forEach {
            contentView.addSubview($0)
        }
        payButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            cardFormView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            cardFormView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cardFormView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            errorLabel.topAnchor.constraint(equalTo: cardFormView.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: cardFormView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: cardFormView.trailingAnchor),

            payButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 28),
            payButton.leadingAnchor.constraint(equalTo: cardFormView.leadingAnchor),
            payButton.trailingAnchor.constraint(equalTo: cardFormView.trailingAnchor),
            payButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
            payButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            activityIndicator.centerXAnchor.constraint(equalTo: payButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: payButton.centerYAnchor)
        ])
    }

    @objc
    private func pay() {
        guard let paymentMethodParams = cardFormView.cardParams else {
            showError("payment.card.incomplete".localized)
            return
        }

        setProcessing(true)
        errorLabel.isHidden = true

        let confirmParams = STPPaymentIntentConfirmParams(clientSecret: clientSecret)
        confirmParams.paymentMethodParams = paymentMethodParams
        confirmParams.returnURL = "medsy://stripe-redirect"

        STPPaymentHandler.shared().confirmPaymentIntent(
            params: confirmParams,
            authenticationContext: self
        ) { [weak self] status, _, error in
            Task { @MainActor [weak self] in
                guard let self else { return }

                switch status {
                case .succeeded:
                    finish(with: .completed)
                case .canceled:
                    setProcessing(false)
                    showError("payment.card.authentication_cancelled".localized)
                case .failed:
                    setProcessing(false)
                    showError(error?.localizedDescription ?? "payment.card.failed".localized)
                @unknown default:
                    setProcessing(false)
                    showError("payment.card.failed".localized)
                }
            }
        }
    }

    @objc
    private func cancel() {
        finish(with: .cancelled)
    }

    private func setProcessing(_ isProcessing: Bool) {
        cardFormView.isUserInteractionEnabled = !isProcessing
        navigationItem.leftBarButtonItem?.isEnabled = !isProcessing
        payButton.configuration?.title = isProcessing ? nil : "payment.card.pay".localized

        if isProcessing {
            payButton.isEnabled = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            payButton.isEnabled = cardFormView.cardParams != nil
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private func finish(with outcome: PaymentSheetPresentationOutcome) {
        guard !didFinish else { return }
        didFinish = true
        dismiss(animated: true) { [completion] in
            completion(outcome)
        }
    }
}

extension CardPaymentViewController: STPCardFormViewDelegate {
    func cardFormView(_ form: STPCardFormView, didChangeToStateComplete complete: Bool) {
        payButton.isEnabled = complete
        if complete {
            errorLabel.isHidden = true
        }
    }
}

extension CardPaymentViewController: STPAuthenticationContext {}

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
