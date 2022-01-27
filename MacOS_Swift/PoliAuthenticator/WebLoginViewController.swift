//
//  WebLoginViewController.swift
//  PoliAuthenticator
//
//

import UIKit
import WebKit

class WebLoginViewController: UIViewController {
    
    private var webView = WKWebView()
    private let closeButton = UIButton()
    private var loader = Loader()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        closeButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        let title = UILabel()
        title.text = "PoliMi Login"
        title.textColor = .black
        title.font = .systemFont(ofSize: 18)
        title.textAlignment = .center
        self.view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        title.heightAnchor.constraint(equalToConstant: 44).isActive = true
        title.rightAnchor.constraint(equalTo: closeButton.leftAnchor, constant: 5).isActive = true
        title.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 95).isActive = true
        
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10).isActive = true
        webView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: AppConst.AUTH_SERVER)!)
        webView.load(request)
    }
    
    @objc private func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension WebLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let currentUrl = webView.url?.absoluteString else {return}
        if(currentUrl.starts(with: AppConst.AUTH_TOKEN_WEB)){
            DispatchQueue.main.async {
                self.loader = CircleLoader.createGeometricLoader()
                self.loader.startAnimation()
            }
            webView.evaluateJavaScript("document.getElementsByTagName('input')[0].value",
                                       completionHandler: { (content: Any?, error: Error?) in
                if let auth_token = content as? String {
                    let statusManager = StatusManager()
                    statusManager.getAccessToken(usingAuthToken: auth_token)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Unable to get your access token, please retry", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
}
