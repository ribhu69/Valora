//
//  SettingsView.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftUI

struct SettingsView : View {
    
    @Environment(\.modelContext) var modelContext
    private var appVersion: String {
        let infoDictionary = Bundle.main.infoDictionary
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        return version
    }
    
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Manrope-Regular", size: UIFont.labelFontSize)!
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "Manrope-Regular", size: 34)!
        ]
        appearance.backgroundColor = UIColor.systemBackground
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
                    Text("App Version")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                    Text("\(appVersion)")
                        .font(.title3)
                        .foregroundStyle(.primary)
                    
                    Link(destination: URL(string: "https://github.com/ribhu69/Valora")!) {
                        Text("@Valora")
                            .font(.title3)
                    }
                    .padding(.top, 16)
                    
                }
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

