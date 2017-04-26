//
//  LoginViewController.swift
//  TaigaMobile
//
//  Created by Dinh Thanh An on 4/13/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa
import Moya
import Moya_ModelMapper
import Mapper

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginGithubButton: UIButton!
    
    var provider: RxMoyaProvider<Taiga>!
    
    let disposeBag = DisposeBag()
    
    var rx_usernameTxtField: Observable<String> {
        return usernameTxtField
                .rx
                .text
                .map(){text -> String in
                    if(text == nil){
                        return ""
                    }else{
                        return text!
                    }
                }
                .distinctUntilChanged()
    }
    var rx_passwordTxtField: Observable<String> {
        return passwordTextField
            .rx
            .text
            .map(){text -> String in
                if(text == nil){
                    return ""
                }else{
                    return text!
                }
            }
            .distinctUntilChanged()
    }
    var rx_loginButton: Observable<(String, String)> {
        return loginButton
            .rx
            .tap
            .map(){
                return (self.usernameTxtField.text!, self.passwordTextField.text!)
            }
    }
    
    var viewModel: LoginViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
        
        bindUI()
    }
    
    func bindUI() {
        let endpointClosure = { (target: Taiga) -> Endpoint<Taiga> in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
        }
        provider = RxMoyaProvider<Taiga>(endpointClosure: endpointClosure)
        
        viewModel = LoginViewModel(rx_username: rx_usernameTxtField, rx_password: rx_passwordTxtField, rx_inputValid: nil, rx_login: rx_loginButton, provider: provider)
        viewModel?.bindModel()
        
        viewModel?.rx_inputValid?.bind(to: loginButton.rx.backgroundColorButton)
        .addDisposableTo(disposeBag)
        
        viewModel?.loginNormal().subscribe(onNext: { [unowned self] success in
            if success {
                let mainVC = Utils.mainStoryBoard().instantiateViewController(withIdentifier: "MainViewController")
                self.navigationController?.pushViewController(mainVC, animated: true)
            } else {
                print("Login Failed")
            }
        })
        .addDisposableTo(disposeBag)
        
//        loginGithubButton.rx.tap
//        .subscribe(onNext: {
//            
//            let apiManager = TMAPIManager()
//            apiManager.loginGitHub()
//            
//        })
//        .addDisposableTo(disposeBag)
        
//        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "GITHUB_LOGIN_CODE"), object: nil)
//        .subscribe(onNext: { [unowned self] notif in
//            let dict = notif.userInfo
//            let url = dict?["url"] as? URL
//            let code = url?.relativeString.components(separatedBy: "?")[1].components(separatedBy: "&")[0].components(separatedBy: "=")[1]
//
//            self.viewModel?.loginTaigaByGithub(code: code!)
//            .subscribe(onNext: { user in
////                print("************** \(user!)")
//            })
//            .addDisposableTo(self.disposeBag)
//        })
//        .addDisposableTo(disposeBag)
        
    }
}

struct LoginViewModel {
    let rx_username: Observable<String>
    let rx_password: Observable<String>
    var rx_inputValid: Observable<ValidationResult>?
    
    var rx_login: Observable<(String, String)>
    
    var provider: RxMoyaProvider<Taiga>!
    let disposeBag = DisposeBag()
    
    mutating func bindModel() {
        let usernameValid = rx_username
            .map { $0.characters.count >= 2 }
            .shareReplay(1) // without this map would be executed once for each binding, rx is stateless by default
        
        let passwordValid = rx_password
            .map { $0.characters.count >= 6 }
            .shareReplay(1)
        
        rx_inputValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .map({ (valid) in
                return valid ? .ok : .failed
            })
            .shareReplay(1)
    }
    
    func loginNormal() -> Observable<Bool> {
        return rx_login
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest({ (username, pass) -> Observable<User?> in
                return self.loginTaigaBy(username: username, password: pass)
            })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ user -> Observable<Bool> in
                if user != nil {
                    User.save(user: user!)
                }
                return Observable.just(user != nil)
            })
    }
    
    internal func loginTaigaByGithub(code: String) -> Observable<User?> {
        return self.provider
            .request(Taiga.githubLogin(code: code))
            .debug()
            .mapObjectOptional(type: User.self)
    }
    
    internal func loginTaigaBy(username: String, password: String) -> Observable<User?> {
        return self.provider
            .request(Taiga.normalLogin(username: username, password: password))
            .debug()
            .mapObjectOptional(type: User.self)
    }
}

extension Reactive where Base: UIButton{
    var backgroundColorButton: UIBindingObserver<Base, ValidationResult> {
        return UIBindingObserver(UIElement: base) { button, validation in
            if validation == .ok {
                button.isEnabled = true
                button.backgroundColor = UIColor.green
            } else if validation == .failed {
                button.isEnabled = false
                button.backgroundColor = UIColor.white
            }
        }
    }
}

enum ValidationResult {
    case ok
    case failed
}
