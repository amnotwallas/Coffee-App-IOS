import UIKit

class CompleteProfileViewController: UIViewController {
    
    private let viewModel: LoginViewModel
    private var selectedCountryCode: String = "+52"
    
    // MARK: - UI Components (Background)
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
        label.text = "Complementa tu perfil"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = BrandColors.darkContrastUI
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Necesitamos estos datos para verificarte y mejorar tu experiencia."
        label.font = .systemFont(ofSize: 12)
        label.textColor = BrandColors.accentUI
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nombre completo"
        tf.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let phoneContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let countryCodeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("🇲🇽 +52", for: .normal)
        btn.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        btn.layer.cornerRadius = 10
        btn.setTitleColor(BrandColors.darkContrastUI, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Teléfono (10 dígitos)"
        tf.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        tf.layer.cornerRadius = 10
        tf.keyboardType = .phonePad
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let finishButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Finalizar Registro", for: .normal)
        btn.backgroundColor = BrandColors.primaryBrandUI
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Init
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrandColors.backgroundUI
        setupHierarchy()
        setupConstraints()
        setupActions()
        setupBindings()
    }

    private func setupHierarchy() {
        view.addSubview(topLeftBean)
        view.addSubview(topRightBean)
        view.addSubview(bottomLeftBean)
        view.addSubview(bottomRightBean)
        
        view.addSubview(cardContainer)
        cardContainer.addSubview(blurEffectView)
        cardContainer.addSubview(titleLabel)
        cardContainer.addSubview(subtitleLabel)
        cardContainer.addSubview(nameTextField)
        cardContainer.addSubview(phoneContainer)
        phoneContainer.addArrangedSubview(countryCodeButton)
        phoneContainer.addArrangedSubview(phoneTextField)
        cardContainer.addSubview(finishButton)
        cardContainer.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
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
            cardContainer.heightAnchor.constraint(equalToConstant: 380),
            
            blurEffectView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -20),

            nameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            phoneContainer.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            phoneContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 20),
            phoneContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -20),
            phoneContainer.heightAnchor.constraint(equalToConstant: 40),
            
            countryCodeButton.widthAnchor.constraint(equalToConstant: 80),
            
            finishButton.topAnchor.constraint(equalTo: phoneContainer.bottomAnchor, constant: 25),
            finishButton.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            finishButton.widthAnchor.constraint(equalToConstant: 200),
            finishButton.heightAnchor.constraint(equalToConstant: 45),
            
            activityIndicator.topAnchor.constraint(equalTo: finishButton.bottomAnchor, constant: 10),
            activityIndicator.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor)
        ])
    }

    private func setupActions() {
        let countries = [
            ("🇲🇽 +52", "+52"),
            ("🇺🇸 +1", "+1"),
            ("🇨🇴 +57", "+57"),
            ("🇪🇸 +34", "+34")
        ]
        
        let actions = countries.map { label, code in
            UIAction(title: label) { [weak self] _ in
                self?.countryCodeButton.setTitle(label, for: .normal)
                self?.selectedCountryCode = code
            }
        }
        
        countryCodeButton.menu = UIMenu(title: "Código de país", children: actions)
        countryCodeButton.showsMenuAsPrimaryAction = true
        
        finishButton.addTarget(self, action: #selector(handleFinish), for: .touchUpInside)
    }

    private func setupBindings() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
                self?.finishButton.isEnabled = false
                self?.finishButton.alpha = 0.5
            } else {
                self?.activityIndicator.stopAnimating()
                self?.finishButton.isEnabled = true
                self?.finishButton.alpha = 1.0
            }
        }
        
        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.onLoginSuccess = { [weak self] in
            self?.view.window?.rootViewController?.dismiss(animated: true)
        }
    }
    
    @objc private func handleFinish() {
        guard let name = nameTextField.text, !name.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty else {
            return
        }
        
        viewModel.finalizeRegistration(nombre: name, telefono: selectedCountryCode + phone)
    }
}
