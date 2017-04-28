//
//  TMAPIManager.swift
//  TaigaMobile
//
//  Created by Dinh Thanh An on 4/17/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation

import OAuthSwift
import RxSwift
import RxCocoa
import Moya
import Moya_ModelMapper
import Mapper

private let githubClientID = "7717167f9b10db259688"
private let githubClientSecret = "4bbffa0cd341a68ae9f4acf70025bb020cbfe183"

class TMAPIManager {
    open class func CustomMoyaProvider() -> RxMoyaProvider<Taiga>!{
        let endpointClosure = { (target: Taiga) -> Endpoint<Taiga> in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            let user = User.getCurrentUser()
            if user != nil {
                return defaultEndpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json", "Authorization": "Bearer \(String(describing: user?.authToken))"])
            }
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
        }
        return RxMoyaProvider<Taiga>(endpointClosure: endpointClosure)
    }
    
    func loginGitHub() {
        let oauthswift = OAuth2Swift(
            consumerKey:    githubClientID,
            consumerSecret: githubClientSecret,
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            responseType:   "access_token"
        )
        _ = oauthswift.authorize(
                withCallbackURL: URL(string: "TaigaMobile://login")!,
                scope: "user:email", state:"GITHUB",
                success: { credential, response, parameters in
                    print(credential.oauthToken)
            },
                failure: { error in
                    print(error.localizedDescription)
            }
        )
    }
}



private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

enum Taiga {
    case githubLogin(code: String)
    case normalLogin(username: String, password: String)
    case listProject()
}

extension Taiga: TargetType {
    var baseURL: URL { return URL(string: "https://api.taiga.io/api/v1")! }
    var path: String {
        switch self {
            case .githubLogin(_), .normalLogin(_, _):
                return "/auth"
            case .listProject():
                return "/projects"
        }
    }
    var method: Moya.Method {
        switch self {
            case .githubLogin(_), .normalLogin(_, _):
                return .post
            case .listProject():
                return .get
        }
        
        
    }
    var parameters: [String: Any]? {
        switch self {
            case .githubLogin(let code):
                return ["type": "github", "code": code]
            case .normalLogin(let username, let password):
                return ["type": "normal", "password": password, "username": username]
            default:
                return [:]
        }
    }
    var sampleData: Data {
        switch self {
            case .githubLogin(_), .normalLogin(_, _), .listProject():
                return "{{\"id\": \"1\", \"language\": \"Swift\", \"url\": \"https://api.github.com/repos/mjacko/Router\", \"name\": \"Router\"}}}".data(using: .utf8)!
        }
    }
    var task: Task {
        return .request
    }
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
}

