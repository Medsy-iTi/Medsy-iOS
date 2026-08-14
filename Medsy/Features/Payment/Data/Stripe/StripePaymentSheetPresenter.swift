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
                navigationController.overrideUserInterfaceStyle = Self.interfaceStyle
                navigationController.modalPresentationStyle = .fullScreen
                viewController.present(navigationController, animated: true)
            }
        }
    }

    private static var interfaceStyle: UIUserInterfaceStyle {
        switch AppSettings.shared.themeMode {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

@MainActor
private final class CardPaymentViewController: UIViewController {
    private let clientSecret: String
    private let completion: (PaymentSheetPresentationOutcome) -> Void
    private var didFinish = false
    private var scrollBottomConstraint: NSLayoutConstraint?
    private var isRTL: Bool { LanguageManager.shared.isRTL }
    private var interfaceStyle: UIUserInterfaceStyle {
        switch AppSettings.shared.themeMode {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        AppSettings.shared.isDarkMode ? .lightContent : .darkContent
    }

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

    private lazy var headerIconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.primaryContainer
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var headerIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "creditcard.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Theme.green
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = Theme.onBackground
        label.textAlignment = isRTL ? .right : .left
        label.text = "payment.card.title".localized
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = Theme.onSurfaceVariant
        label.textAlignment = isRTL ? .right : .left
        label.text = "payment.card.subtitle".localized
        return label
    }()

    private lazy var headerTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 6
        return stackView
    }()

    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerIconView, headerTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 16
        stackView.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        return stackView
    }()

    private lazy var cardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.cardSurface
        view.layer.cornerRadius = 20
        view.layer.cornerCurve = .continuous
        view.layer.borderColor = Theme.outlineVariant.cgColor
        view.layer.borderWidth = 1
        view.layer.shadowColor = Theme.shadow.cgColor
        view.layer.shadowOpacity = Theme.cardShadowOpacity
        view.layer.shadowRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        return view
    }()

    private lazy var cardFormView: STPCardFormView = {
        let view = STPCardFormView(style: .standard)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.semanticContentAttribute = .forceLeftToRight
        view.overrideUserInterfaceStyle = interfaceStyle
        view.delegate = self
        view.backgroundColor = Theme.inputSurface
        view.disabledBackgroundColor = Theme.disabledSurface
        view.tintColor = Theme.green
        view.accessibilityLabel = "payment.card.details".localized
        return view
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = Theme.error
        label.textAlignment = isRTL ? .right : .left
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
        configuration.baseBackgroundColor = Theme.green
        configuration.baseForegroundColor = Theme.onPrimary
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 20,
            bottom: 16,
            trailing: 20
        )
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer {
            var attributes = $0
            attributes.font = .preferredFont(forTextStyle: .headline)
            return attributes
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.configurationUpdateHandler = { button in
            guard var configuration = button.configuration else { return }
            configuration.baseBackgroundColor = button.isEnabled
                ? Theme.green
                : Theme.disabledButton
            configuration.baseForegroundColor = button.isEnabled
                ? Theme.onPrimary
                : Theme.disabledButtonText
            button.configuration = configuration
        }
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
        overrideUserInterfaceStyle = interfaceStyle
        configureView()
        configureLayout()
        configureKeyboardObservers()
    }

    func authenticationPresentingViewController() -> UIViewController {
        topmostPresentedViewController
    }

    private func configureView() {
        view.backgroundColor = Theme.background
        view.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        navigationItem.title = "payment.card.navigation_title".localized
        navigationController?.navigationBar.tintColor = Theme.green
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Theme.onBackground
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: Theme.onBackground
        ]
        navigationController?.navigationBar.standardAppearance = themedNavigationAppearance()
        navigationController?.navigationBar.scrollEdgeAppearance = themedNavigationAppearance()
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

        [headerStackView, cardContainerView, errorLabel, payButton].forEach {
            contentView.addSubview($0)
        }
        headerIconView.addSubview(headerIconImageView)
        cardContainerView.addSubview(cardFormView)
        payButton.addSubview(activityIndicator)

        let bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        scrollBottomConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            headerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            headerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            headerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            headerIconView.widthAnchor.constraint(equalToConstant: 56),
            headerIconView.heightAnchor.constraint(equalToConstant: 56),

            headerIconImageView.centerXAnchor.constraint(equalTo: headerIconView.centerXAnchor),
            headerIconImageView.centerYAnchor.constraint(equalTo: headerIconView.centerYAnchor),
            headerIconImageView.widthAnchor.constraint(equalToConstant: 26),
            headerIconImageView.heightAnchor.constraint(equalToConstant: 26),

            cardContainerView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 24),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            cardFormView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 16),
            cardFormView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            cardFormView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            cardFormView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -16),

            errorLabel.topAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),

            payButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            payButton.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            payButton.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            payButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
            payButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            activityIndicator.centerXAnchor.constraint(equalTo: payButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: payButton.centerYAnchor)
        ])
    }

    private func configureKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func themedNavigationAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.background
        appearance.titleTextAttributes = [.foregroundColor: Theme.onBackground]
        appearance.shadowColor = Theme.outlineVariant
        return appearance
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

    @objc
    private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let window = view.window
        else { return }

        let keyboardFrame = view.convert(endFrame, from: window)
        let overlap = max(0, view.bounds.maxY - keyboardFrame.minY - view.safeAreaInsets.bottom)
        scrollBottomConstraint?.constant = -overlap
        animateKeyboardChange(notification)
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        scrollBottomConstraint?.constant = 0
        animateKeyboardChange(notification)
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

    private func animateKeyboardChange(_ notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }

    private func finish(with outcome: PaymentSheetPresentationOutcome) {
        guard !didFinish else { return }
        didFinish = true

        completion(outcome)
        navigationController?.dismiss(animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

private enum Theme {
    private static var isDarkMode: Bool { AppSettings.shared.isDarkMode }

    static var background: UIColor {
        isDarkMode ? UIColor(hex: "#0B1014") : UIColor(hex: "#F7F9F8")
    }

    static var cardSurface: UIColor {
        isDarkMode ? UIColor(hex: "#11191D") : UIColor(hex: "#FFFFFF")
    }

    static var inputSurface: UIColor {
        isDarkMode ? UIColor(hex: "#1A2328") : UIColor(hex: "#F8FAF9")
    }

    static var disabledSurface: UIColor {
        isDarkMode ? UIColor(hex: "#202A2F") : UIColor(hex: "#EEF2EF")
    }

    static var disabledButton: UIColor {
        isDarkMode ? UIColor(hex: "#24352D") : UIColor(hex: "#DCE8E1")
    }

    static var disabledButtonText: UIColor {
        isDarkMode ? UIColor(hex: "#A9BBB1") : UIColor(hex: "#607268")
    }

    static var primaryContainer: UIColor {
        isDarkMode ? UIColor(hex: "#123D2B") : UIColor(hex: "#D6F5E2")
    }

    static var onBackground: UIColor {
        isDarkMode ? UIColor(hex: "#E1E6E3") : UIColor(hex: "#181C19")
    }

    static var onSurfaceVariant: UIColor {
        isDarkMode ? UIColor(hex: "#BEC9C2") : UIColor(hex: "#414943")
    }

    static var outlineVariant: UIColor {
        isDarkMode ? UIColor(hex: "#53615A") : UIColor(hex: "#C0C9C2")
    }

    static var green: UIColor {
        isDarkMode ? UIColor(hex: "#27C779") : UIColor(hex: "#048C4E")
    }

    static var onPrimary: UIColor {
        UIColor(hex: "#FFFFFF")
    }

    static var error: UIColor {
        isDarkMode ? UIColor(hex: "#FFB4AB") : UIColor(hex: "#BA1A1A")
    }

    static var shadow: UIColor {
        UIColor.black
    }

    static var cardShadowOpacity: Float {
        isDarkMode ? 0.22 : 0.08
    }
}

private extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)

        let red = CGFloat((value >> 16) & 0xFF) / 255
        let green = CGFloat((value >> 8) & 0xFF) / 255
        let blue = CGFloat(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
