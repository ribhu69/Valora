//
//  SettingsView.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftUI


struct SettingsView : View {
    
    
    @State private var updateMasterKey = false
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
                    
                    VStack(alignment: .leading) {
                        Text("Update Master Key")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .padding(.bottom, 8)
                        Text("Lets you change your app's master key.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                    }
                    .padding(.top, 8)
                    .onTapGesture {
                        updateMasterKey.toggle()
                    }
                    
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
        .sheet(isPresented: $updateMasterKey, content: {
            SetupMasterKeyForm(isEditMode: true) {
                isEditMode,masterKey  in
                if isEditMode {
                    _ = AppSecurity.shared.updateValueInKeychain(value: masterKey)
                }
            }
        })
    }
}

//#Preview {
//    SettingsView()
//}
//
