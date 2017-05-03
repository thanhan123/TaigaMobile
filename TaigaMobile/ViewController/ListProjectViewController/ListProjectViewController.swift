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
import Moya
import RxOptional

class ListProjectViewController: UIViewController {
    @IBOutlet weak var projectsTableView: UITableView!
    @IBOutlet weak var testButton: UIButton!
    
    let disposeBag = DisposeBag()
    var viewModel: ListProjectViewModel? = nil
    var rx_testButton: Observable<Void>{
        return testButton
                .rx
                .tap
                .map{
                    return
                }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUI()
    }
    
    func bindUI() {
        viewModel = ListProjectViewModel(rx_testButton: rx_testButton, provider: TMAPIManager.CustomMoyaProvider())
        
        viewModel?
        .loadListProject()
        .subscribe(onNext: { projectArray in
            print(projectArray)
        })
//        .subscribeOn(MainScheduler.instance)
//        .bind(to: projectsTableView.rx.items){ tableView, row, item in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: IndexPath(row: row, section: 0))
//            cell.textLabel?.text = item.name
//            
//            return cell
//        }
        .addDisposableTo(disposeBag)
    }
    
    func setupUI() {
        self.title = "Projects"
    }
}

struct ListProjectViewModel {
    let rx_testButton: Observable<Void>
    var provider: RxMoyaProvider<Taiga>!
    
    func loadListProject() -> Observable<[Project]>{
        return rx_testButton
                .flatMap({
                    return self.listProject()
                })
                .flatMap({ listProject -> Observable<[Project]> in
                    print(listProject)
                    return self.listProject()
                })
    }
    
    private func listProject() -> Observable<[Project]>{
        return self.provider
        .request(Taiga.listProject())
        .debug()
        .mapArray(type: Project.self)
    }
}
