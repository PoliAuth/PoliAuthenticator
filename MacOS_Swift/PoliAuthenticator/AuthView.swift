//
//  AuthView.swift
//  PoliAuthenticator
//
//

import Foundation
import UIKit

class AuthView: UIView {
    
    private let pinTF = UITextField()
    private let messageLabel = UILabel()
    private let confirmButton = UIButton()
    private let logoutButton = UIButton()
    
    open var pinText: String{
        get {
            return pinTF.text!
        }
    }
    
    open var logoutAction: ()->() = {}
    open var confirmAction: ()->() = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(pinTF)
        self.addSubview(messageLabel)
    
        
        pinTF.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
    
        
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        messageLabel.text = "The app is protected by a PIN, please insert the pin to continue. If you forgot the PIN please logout"
        messageLabel.numberOfLines = .zero
        messageLabel.font = .systemFont(ofSize: 16)
        
        pinTF.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 15).isActive = true
        pinTF.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        pinTF.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        pinTF.heightAnchor.constraint(equalToConstant: 44).isActive = true
        pinTF.isSecureTextEntry = true
        pinTF.placeholder = "Insert your PIN"
        pinTF.borderStyle = .roundedRect
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 25
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(logoutButton)
        stackView.addArrangedSubview(confirmButton)
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.systemBlue, for: .normal)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
    }
    
    @objc private func didTapConfirm() {
        confirmAction()
    }
    
    @objc private func didTapLogout() {
        logoutAction()
    }
    
}
