//
//  ValoraTabView.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftUI

struct ValoraTabView : View {
    var body: some View {
        NavigationStack {
            TabView {
                PasscodeListView()
                    .tabItem {
                        Image(systemName: "list.clipboard")
                            .renderingMode(.template)
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")

                            .renderingMode(.template)
                    }
            }
        }
    }
}
