//
//  LoginViewController.swift
//  TaigaMobile
//
//  Created by Dinh Thanh An on 4/13/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation
import UIKit

import ReactiveCocoa
import ReactiveSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginGithubButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    func bindUI() {
        let username = usernameTxtField.reactive.continuousTextValues
        let password = passwordTextField.reactive.continuousTextValues
        
        loginButton.isEnabled = false
        loginButton.reactive.isEnabled <~ Signal.combineLatest(username, password)
            .map { usrn, pass in
                return (usrn?.characters.count)! > 0 && (pass?.characters.count)! > 0
        }
        loginButton.reactive.controlEvents(.touchUpInside)
        .observeValues { (sender) in
            
        }
    }
}
