//
//  Credential.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftData

@Model
final class Credential {
    var uuid: UUID
    var webURL : String?
    var userId: String
    var password: String
    var desc: String
    
    init(uuid: UUID, webURL: String? = nil, userId: String, password: String, desc: String) {
        self.uuid = uuid
        self.webURL = webURL
        self.userId = userId
        self.password = password
        self.desc = desc
    }
}

extension Credential {
    static func dummyList() -> [Credential] {
            return [
                Credential(uuid: UUID(), webURL: "https://example.com", userId: "user1", password: "password1", desc: "Test"),
                Credential(uuid: UUID(), webURL: "https://testsite.com", userId: "testuser", password: "testpass", desc: "Test"),
                Credential(uuid: UUID(), webURL: nil, userId: "admin", password: "admin123", desc: "Test"),
                Credential(uuid: UUID(), webURL: "https://secureportal.com", userId: "secureuser", password: "securepass", desc: "Test"),
                Credential(uuid: UUID(), webURL: "https://sampleapp.com", userId: "sampleuser", password: "samplepass", desc: "Test"),
            ]
        }
}
