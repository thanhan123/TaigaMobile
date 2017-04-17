//
//  TMAPIManager.swift
//  TaigaMobile
//
//  Created by Dinh Thanh An on 4/17/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation

import Alamofire

typealias HandlerOnSuccess = (_ responseObject: AnyObject?) -> Void
typealias HandlerOnFailure = (_ error: Error?) -> Void

class TMAPIManager: NSObject {
    let githubClientID = "7717167f9b10db259688"
    let githubClientSecret = "4bbffa0cd341a68ae9f4acf70025bb020cbfe183"
}
