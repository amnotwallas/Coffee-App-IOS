//
//  LoginViewController.swift
//  The-Casa-App
//
//  Created by Walter Jahir Ambriz Reyna on 12/05/26.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let topLeftBean: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "bg-bean-top-left"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let topRightBean: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "bg-bean-top-right"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let bottomLeftBean: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "bg-bean-bottom-left"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let bottomRightBean: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "bg-bean-bottom-right"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        view.layer.cornerRadius = 30
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.layer.cornerRadius = 30
        effectView.clipsToBounds = true
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "¡El mejor café de la ciudad!"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = BrandColors.darkContrastUI
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailContinueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continuar con Email", for: .normal)
        btn.backgroundColor = BrandColors.primaryBrandUI
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let googleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continuar con Google", for: .normal)
        btn.backgroundColor = UIColor.white
        btn.setTitleColor(BrandColors.primaryBrandUI, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1
        btn.layer.borderColor = BrandColors.accentUI.withAlphaComponent(0.3).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(named: "google-icon"))
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(icon)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 15),
            icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 23)
        ])
        
        return btn
    }()
    
    private let skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Explorar sin cuenta", for: .normal)
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(BrandColors.primaryBrandUI, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = BrandColors.darkContrastUI.withAlphaComponent(0.8)
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = BrandColors.primaryBrandUI
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    // MARK: - Properties
    private let viewModel = LoginViewModel()
    
    var onLoginSuccess: (() -> Void)?
    var onCancel: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        setupHierarchy()
        setupConstraints()
        setupActions()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.cardContainer.alpha = 0.5
                    self?.view.isUserInteractionEnabled = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.cardContainer.alpha = 1.0
                    self?.view.isUserInteractionEnabled = true
                }
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error de Autenticación", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Entendido", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        viewModel.onLoginSuccess = { [weak self] in
            print("🚀 LoginViewController: Éxito detectado, notificando...")
            self?.onLoginSuccess?()
        }
    }
    
    private func setupTheme() {
        view.backgroundColor = BrandColors.backgroundUI
    }
    
    private func setupHierarchy() {
        // Añadir fondos primero
        view.addSubview(topLeftBean)
        view.addSubview(topRightBean)
        view.addSubview(bottomLeftBean)
        view.addSubview(bottomRightBean)
        
        // Añadir tarjeta central
        view.addSubview(cardContainer)
        cardContainer.addSubview(blurEffectView)
        
        cardContainer.addSubview(titleLabel)
        cardContainer.addSubview(emailContinueButton)
        cardContainer.addSubview(googleButton)
        cardContainer.addSubview(skipButton)
        
        // Indicador de carga
        view.addSubview(activityIndicator)
        
        // Añadir el botón de cerrar al final para que esté al frente de TODO
        view.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Centrar indicador de carga
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Botón cerrar
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            topLeftBean.topAnchor.constraint(equalTo: view.topAnchor, constant: -73),
            topLeftBean.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -99),
            topLeftBean.widthAnchor.constraint(equalToConstant: 362),
            topLeftBean.heightAnchor.constraint(equalToConstant: 325),
            
            topRightBean.topAnchor.constraint(equalTo: view.topAnchor, constant: -118),
            topRightBean.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 118),
            topRightBean.widthAnchor.constraint(equalToConstant: 325),
            topRightBean.heightAnchor.constraint(equalToConstant: 375),
            
            bottomLeftBean.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            bottomLeftBean.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -133),
            bottomLeftBean.widthAnchor.constraint(equalToConstant: 287),
            bottomLeftBean.heightAnchor.constraint(equalToConstant: 264),
            
            bottomRightBean.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50),
            bottomRightBean.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 80),
            bottomRightBean.widthAnchor.constraint(equalToConstant: 273),
            bottomRightBean.heightAnchor.constraint(equalToConstant: 296),
            
            cardContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardContainer.widthAnchor.constraint(equalToConstant: 311),
            cardContainer.heightAnchor.constraint(equalToConstant: 280),
            
            blurEffectView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            
            emailContinueButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            emailContinueButton.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            emailContinueButton.widthAnchor.constraint(equalToConstant: 267),
            emailContinueButton.heightAnchor.constraint(equalToConstant: 46),
            
            googleButton.topAnchor.constraint(equalTo: emailContinueButton.bottomAnchor, constant: 15),
            googleButton.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            googleButton.widthAnchor.constraint(equalToConstant: 267),
            googleButton.heightAnchor.constraint(equalToConstant: 46),
            
            skipButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 15),
            skipButton.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            skipButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        emailContinueButton.addTarget(self, action: #selector(handleEmailTap), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(handleSkipTap), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(handleGoogleTap), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(handleCloseTap), for: .touchUpInside)
    }
    
    @objc private func handleCloseTap() {
        onCancel?()
    }
    
    @objc private func handleEmailTap() {
        let emailVC = EmailLoginViewController(viewModel: viewModel)
        emailVC.onCancel = onCancel
        emailVC.modalPresentationStyle = .fullScreen
        present(emailVC, animated: true)
    }
    
    @objc private func handleSkipTap() {
        viewModel.handleSkip()
    }
    
    @objc private func handleGoogleTap() {
        viewModel.handleGoogleLogin(presentingViewController: self)
    }
}
