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

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginGithubButton: UIButton!
    
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
    
    var viewModel: LoginViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    func bindUI() {
        viewModel = LoginViewModel(rx_username: rx_usernameTxtField, rx_password: rx_passwordTxtField, rx_inputValid: nil)
        viewModel?.bindModel()
        
        loginButton.rx.tap
        .subscribe(onNext: { [unowned self] in
            
            print("login button tap")
        
        })
        .addDisposableTo(disposeBag)
        
        viewModel?.rx_inputValid?.bind(to: loginButton.rx.backgroundColorButton)
        .addDisposableTo(disposeBag)
    }
}

struct LoginViewModel {
    let rx_username: Observable<String>
    let rx_password: Observable<String>
    var rx_inputValid: Observable<ValidationResult>?
    
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
