//
//  ViewController.swift
//  PoliBrowser
//
//

import UIKit

class ViewController: UIViewController {
    
    private var mainView = MainView()
    private var authView = AuthView()
    private let statusManager = StatusManager()
    private var currentDisplayView: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.hideKeyboardWhenTappedAround()
        StatusManager.registerForStatus(statusManagerDelegate: self)
        if SharedPreferencesManager.isPinConfigured() && SharedPreferencesManager.isUsinsPin() && StatusManager.pin == "" {
            prepareAuthView()
            currentDisplayView = authView
            StatusManager.notifyStatusUpdate(status: .LOCKED)
        } else {
            prepareMainView()
            currentDisplayView = mainView
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusManager.updateAppToken()
        
    }
    
    private func prepareMainView() {
        mainView.logoutAction = {
            let logoutAlert = UIAlertController(title: "Logout", message: "Are you sure you want log out?", preferredStyle: .alert)
            logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            logoutAlert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: {_ in
                SharedPreferencesManager.deletePreferences()
                StatusManager.notifyStatusUpdate(status: .UNLOGGED)

            }))
            self.present(logoutAlert, animated: true, completion: nil)
        }
        
        mainView.loginAction = { [weak self] in
            self?.presentLoginController()
        }
        
        mainView.urlAction = {
            self.openWebBroser()
        }
    
        
        self.view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        mainView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    private func prepareAuthView() {
        authView.logoutAction = {
            let logoutAlert = UIAlertController(title: "Logout", message: "Are you sure you want log out?", preferredStyle: .alert)
            logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            logoutAlert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: {_ in
                SharedPreferencesManager.deletePreferences()
                StatusManager.notifyStatusUpdate(status: .UNLOGGED)

            }))
            self.present(logoutAlert, animated: true, completion: nil)
        }
        
        authView.confirmAction = {
            let pin = self.authView.pinText
            if (pin.sha256() == SharedPreferencesManager.getAuthPin()){
                StatusManager.pin = pin
                self.statusManager.updateAppToken()
            } else {
                let alert = UIAlertController(title: "Wrong pin", message: "You inserted a wrong pin", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        self.view.addSubview(authView)
        authView.translatesAutoresizingMaskIntoConstraints = false
        authView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        authView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        authView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        authView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func loadMainView() {
        if let cV = currentDisplayView {
            cV.removeFromSuperview()
        }
        prepareMainView()
    }
    
    private func loadAuthView() {
        if let cV = currentDisplayView {
            cV.removeFromSuperview()
        }
        prepareAuthView()
    }
    
    private func presentLoginController() {
        let loginVC = WebLoginViewController()
        self.present(loginVC, animated: true, completion: nil)
    }
    
    
    private func openWebBroser() {
        if SharedPreferencesManager.isUsinsPin(){
            guard let accessToken = SharedPreferencesManager.getAccessToken(withPin: true, pin: StatusManager.pin) else {return}
            let poliUrl = AppConst.WEBEEP_URL + accessToken
            UIApplication.shared.open(URL(string: poliUrl)!)
                   
        } else {
            guard let accessToken = SharedPreferencesManager.getAccessToken(withPin: false, pin: "") else {return}
            let poliUrl = AppConst.WEBEEP_URL + accessToken
            UIApplication.shared.open(URL(string: poliUrl)!)
        }
        
    }
    
}


extension ViewController: StatusManagerDelegate {
    func onStatusUpdate(appStatus: AppStatus) {
        if (SharedPreferencesManager.isUserLogged() && !SharedPreferencesManager.isPinConfigured()) {
            let ac = UIAlertController(title: "Configure a pin", message: "Insert a pin to protect your app or ignore", preferredStyle: .alert)
            ac.addTextField { tf in
                tf.placeholder = "Insert PIN"
                tf.isSecureTextEntry = true
            }
              
            let noPinAction = UIAlertAction(title: "Ignore", style: .cancel) { _ in
                SharedPreferencesManager.setUserPin(usePin: false, pin: "")
            }
                
               let submitAction = UIAlertAction(title: "Add pin", style: .default) { [unowned ac] _ in
                   let answer = ac.textFields![0]
                   if(answer.text!.isEmpty){
                       let errorAlert = UIAlertController(title: "Error", message: "The pin mustn't be empty", preferredStyle: .alert)
                       errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                           StatusManager.notifyStatusUpdate(status: appStatus)
                           return
                       }))
                       self.present(errorAlert, animated: true, completion: nil)
                   } else {
                       StatusManager.pin = answer.text!
                       SharedPreferencesManager.setUserPin(usePin: true, pin: answer.text!)
                   }
               }
                ac.addAction(noPinAction)
               ac.addAction(submitAction)

               present(ac, animated: true)
        }
        
        if appStatus != .LOCKED {
            if let _ = currentDisplayView as? AuthView {
                    loadMainView()
            }
            self.mainView.appStatus = appStatus
        }
    }
}
