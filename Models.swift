//
//  Models.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/16/25.
//

import Foundation
import ParseSwift

struct AppUser: ParseUser {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var username: String?
    var password: String?
    var email: String?
    var emailVerified: Bool?
    var authData: [String : [String : String]?]?
    
    var lastPostedAt: Date?
    
    init() {}
}

struct Post: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    var author: AppUser?
    var caption: String?
    var image: ParseFile?
    
    var location: ParseGeoPoint?
    
    init() {}
}

struct Comment: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var author: AppUser?
    var post: Post?
    var text: String?
    
    init() {}
}
