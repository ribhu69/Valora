//
//  AppStart.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 21/09/24.
//

import Foundation

class AppStart {
    static func initialize() -> ValoraTabView {
        _ = DatabaseManager.shared
        return ValoraTabView()
    }
}
