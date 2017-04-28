//
//  ListProjectViewController.swift
//  TaigaMobile
//
//  Created by Dinh Thanh An on 4/28/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
class ListProjectViewController: UIViewController {
    @IBOutlet weak var projectsTableView: UITableView!
    
    let disposeBag = DisposeBag()
    var viewModel: ListProjectViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUI()
    }
    
    func bindUI() {
        
    }
    
    func setupUI() {
        self.title = "Projects"
    }
}

struct ListProjectViewModel {
    let listProject: Observable<Void>
    
//    func getListProject() -> Observable<[Project]> {
//        
//    }
}
