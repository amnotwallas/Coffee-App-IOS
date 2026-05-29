//
//  LoadingViewController.swift
//  The-Casa-App
//
//  Created by Walter Jahir Ambriz Reyna on 12/05/26.
//

import UIKit
import SwiftUI

class LoadingViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AppLogo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(
            red: 255/255.0,
            green: 249/255.0,
            blue: 241/255.0,
            alpha: 1.0
        )
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        iniciarAnimaciones()
    }
    
    private func setupUI() {
        
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 280),
            logoImageView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func iniciarAnimaciones() {
        // Entrada con resorte
        logoImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.logoImageView.alpha = 1.0
            self.logoImageView.transform = .identity
        }, completion: { _ in
            // Animación de respiración infinita
            self.animacionRespiracion()
        })
    }
    
    private func animacionRespiracion() {
        UIView.animate(withDuration: 2.0, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction, .curveEaseInOut], animations: {
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: nil)
    }
}
