//
//  MainView.swift
//  PoliBrowser
//
//

import Foundation
import UIKit

class MainView: UIView {
    private let loginButton = UIButton()
    private let logoutButton = UIButton()
    private let messageLabel = UILabel()
    private let statusLabel = UILabel()
    private let openUrlButton = UIButton()
    
    open var loginAction: ()->() = {}
    open var logoutAction: ()->() = {}
    open var urlAction: ()->() = {}
    
    open var appStatus: AppStatus = .UNLOGGED {
        didSet {
            performViewChanges(forAppStatus: appStatus)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(loginButton)
        self.addSubview(logoutButton)
        self.addSubview(messageLabel)
        self.addSubview(statusLabel)
    
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        openUrlButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        loginButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        loginButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        
        logoutButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        logoutButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        logoutButton.backgroundColor = .systemBlue
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.layer.cornerRadius = 10
        
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: loginButton.leftAnchor, constant: -20).isActive = true
        messageLabel.numberOfLines = .zero
        messageLabel.textColor = .black
        messageLabel.font = .boldSystemFont(ofSize: 20)
        messageLabel.text = "Welcome in PoliAuthenticator"
        messageLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        statusLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10).isActive = true
        statusLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        statusLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        statusLabel.heightAnchor.constraint(equalToConstant: 55).isActive = true
        statusLabel.numberOfLines = .zero
        statusLabel.textAlignment = .center
        statusLabel.textColor = .black
        statusLabel.font = .boldSystemFont(ofSize: 25)
        statusLabel.text = "---"
        
        let containerView = UIView()
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        

        
        containerView.addSubview(openUrlButton)
        openUrlButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        openUrlButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        openUrlButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        openUrlButton.layer.borderWidth = 0.5
        openUrlButton.layer.borderColor = UIColor.black.cgColor
        openUrlButton.layer.cornerRadius = 10
        openUrlButton.layer.masksToBounds = true
        openUrlButton.setTitle("Click here to continue in browser", for: .normal)
        openUrlButton.titleLabel?.font = .boldSystemFont(ofSize: 25)
        openUrlButton.titleLabel?.numberOfLines = .zero
        openUrlButton.setTitleColor(.black, for: .normal)
        openUrlButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        openUrlButton.addTarget(self, action: #selector(didTapUrl), for: .touchUpInside)
        
    }
    
    private func performViewChanges(forAppStatus appStatus: AppStatus) {
        switch appStatus {
        case .UNLOGGED:
            statusLabel.text = "You are not authenticated"
            statusLabel.textColor = UIColor(named: "redColor")!
            loginButton.isHidden = false
            logoutButton.isHidden = true
            openUrlButton.isHidden = true
            break
        case .TOKEN_VALID:
            statusLabel.text = "You are authenticated"
            statusLabel.textColor = UIColor(named: "greenColor")!
            loginButton.isHidden = true
            logoutButton.isHidden = false
            openUrlButton.isHidden = false
            break
        case .TOKEN_NOT_VALID:
            statusLabel.text = "Your token is expired... updating"
            statusLabel.textColor = UIColor(named: "orangeColor")!
            loginButton.isHidden = true
            logoutButton.isHidden = true
            openUrlButton.isHidden = true
            break
        default:
            break
        }
    }
    
    @objc private func didTapLogin() {
        self.loginAction()
    }
    
    @objc private func didTapLogout() {
        self.logoutAction()
    }
    
    @objc private func didTapUrl() {
        self.urlAction()
    }
}
