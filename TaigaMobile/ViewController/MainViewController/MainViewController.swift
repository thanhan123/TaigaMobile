//
//  MainViewController.swift
//  TaigaMobile
//
//  Created by Dinh Thanh An on 4/25/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    @IBOutlet weak var lisetProjectButton: UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main"
        self.navigationItem.leftBarButtonItem = nil
        
        bindUI()
        setupUI()
    }
    
    func bindUI() {
        lisetProjectButton.rx.tap
        .subscribe(onNext: { [unowned self] in
            let listProjectVC = Utils.mainStoryBoard().instantiateViewController(withIdentifier: "ListProjectViewController")
            self.navigationController?.pushViewController(listProjectVC, animated: true)
        })
        .addDisposableTo(disposeBag)
    }
    
    func setupUI() {
        let user = User.getCurrentUser()
        usernameLabel.text = user?.username
        bioLabel.text = user?.bio
        userProfileImageView.clipsToBounds = true;
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.height / 2
        userProfileImageView.sd_setImage(with: URL(string: (user?.photo)!))
    }
}

