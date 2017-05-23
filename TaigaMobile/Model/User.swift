//
//  User.swift
//  TaigaMobile
//
//  Created by Dinh Thanh An on 4/26/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation
import Moya_ModelMapper
import Mapper

struct User: Mappable {
    
    let authToken: String?
    let bio: String?
    let email: String?
    let fullName: String?
    let username: String?
    let photo: String?
    let userId: Double?
    
    init(map: Mapper) throws {
        try userId = map.from("id")
        try authToken = map.from("auth_token")
        try bio = map.from("bio")
        try email = map.from("email")
        try fullName = map.from("full_name")
        try username = map.from("username")
        photo = map.optionalFrom("photo")
    }
    
    init(dict: Dictionary<String, Any>) {
        authToken = dict["authToken"] as? String
        bio = dict["bio"] as? String
        email = dict["email"] as? String
        fullName = dict["full_name"] as? String
        username = dict["username"] as? String
        photo = dict["photo"] as? String
        userId = dict["id"] as? Double
    }
    
    static func save(user: User) {
        let personClassObject = UserClass(user: user)
        personClassObject.saveCurrentUser()
    }
    
    static func getCurrentUser() -> User? {
        let userClassObject = UserClass.currentUser()
        return userClassObject?.user
    }
}

extension User {
    class UserClass: NSObject, NSCoding {
        
        var user: User?
        
        init(user: User) {
            self.user = user
            super.init()
        }
        
        required init?(coder aDecoder: NSCoder) {
            let authToken = aDecoder.decodeObject(forKey: "authToken") ?? String()
            let bio = aDecoder.decodeObject(forKey: "bio") ?? String()
            let email = aDecoder.decodeObject(forKey: "email") ?? String()
            let fullName = aDecoder.decodeObject(forKey: "fullName") ?? String()
            let username = aDecoder.decodeObject(forKey: "username") ?? String()
            let photo = aDecoder.decodeObject(forKey: "photo") ?? String()
            let userId = aDecoder.decodeObject(forKey: "userId") ?? String()
            
            let dict = ["authToken": authToken, "bio": bio, "email": email, "full_name": fullName, "username": username, "photo": photo, "id": userId]
            user = User(dict: dict)
            
            super.init()
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(user!.authToken, forKey: "authToken")
            aCoder.encode(user!.bio, forKey: "bio")
            aCoder.encode(user!.email, forKey: "email")
            aCoder.encode(user!.fullName, forKey: "fullName")
            aCoder.encode(user!.username, forKey: "username")
            aCoder.encode(user!.photo, forKey: "photo")
            aCoder.encode(user!.userId, forKey: "userId")
        }
        
        func saveCurrentUser() {
            let encodedUserObject = NSKeyedArchiver.archivedData(withRootObject: self)
            UserDefaults.standard.set(encodedUserObject, forKey: "KEY_CURRENT_USER")
        }
        
        open class func currentUser() -> UserClass? {
            let encodedUserObject = UserDefaults.standard.object(forKey: "KEY_CURRENT_USER")
            if encodedUserObject == nil {
                return nil
            }
            let user = NSKeyedUnarchiver.unarchiveObject(with: encodedUserObject as! Data)
            
            return user as? User.UserClass
        }
    }
}
