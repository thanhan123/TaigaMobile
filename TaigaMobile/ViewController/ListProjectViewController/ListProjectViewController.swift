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
    
    let disposeBag = DisposeBag()
    var viewModel: ListProjectViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUI()
    }
    
    func bindUI() {
        viewModel = ListProjectViewModel(provider: TMAPIManager.CustomMoyaProvider())
        
        viewModel?
        .loadListProject()
        .subscribeOn(MainScheduler.instance)
        .bind(to: projectsTableView.rx.items){ tableView, row, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: IndexPath(row: row, section: 0))
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.description
            return cell
        }
        .addDisposableTo(disposeBag)
    }
    
    func setupUI() {
        self.title = "Projects"
        projectsTableView.tableFooterView = UIView()
    }
}

struct ListProjectViewModel {
    var provider: RxMoyaProvider<Taiga>!
    
    func loadListProject() -> Observable<[Project]>{
        return self.listProject()
    }
    
    private func listProject() -> Observable<[Project]>{
        let paramsString = ["member": String(format:"%.0f", (User.getCurrentUser()?.userId)!)].stringFromHttpParameters()
        let url = URL(string: "https://api.taiga.io/api/v1/projects?\(paramsString)")
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(User.getCurrentUser()?.authToken, forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.rx
        .json(request: urlRequest)
        .map{
            var repositories = [Project]()
            
            if let items = $0 as? [[String: AnyObject]] {
                items.forEach {
                    guard
                        let name = $0["name"] as? String,
                        let desc = $0["description"] as? String
                        else { return }
                    repositories.append(Project(dict: ["name": name, "description": desc]))
                }
            }
            
            return repositories
        }
        
        
//        return self.provider
//        .request(Taiga.listProject())
//        .debug()
//        .mapArray(type: Project.self)
    }
}

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
