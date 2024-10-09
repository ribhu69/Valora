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
    var webURL : String
    var userId: Data
    var password: Data
    var desc: String?
    
    init(uuid: UUID, webURL: String, userId: Data, password: Data, desc: String? = nil) {
        self.uuid = uuid
        self.webURL = webURL
        self.userId = userId
        self.password = password
        self.desc = desc
    }
}

extension Credential {
    static func dummyList() -> [Credential] {
        return []
        }
}
