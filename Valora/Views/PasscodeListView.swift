//
//  ValoraList.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftUI
import SwiftData
import Security
import CryptoKit

struct PassCodeCellView: View {
    var credential: Credential
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        HStack {
            Image(getImage(for: credential.webURL))
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.secondary)
                    .frame(width: 18, height: 18)
                    .padding(.leading, 8)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(credential.webURL)
                        .font(.custom("Manrope-Regular", size: 21))
                    
                }
    
                if let desc = credential.desc {
                    Text(desc)
                        .font(.custom("Manrope-Regular", size: 17))
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                        
                }
            }
            .padding(.horizontal, 8)
            Spacer()
            Button(action: {
                generateHapticFeedback()
                UIPasteboard.general.string = credential.webURL
                
            }, label: {
                Image("copyLink")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 21, height: 21)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            })
        }
    }
    
    func generateHapticFeedback() {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    
    func getImage(for url: String?) -> String {
        guard let urlString = url, let domain = getDomain(from: urlString) else {
            return "globe" // Fallback image when there's no URL
        }
        
        let domainImageName = domain.lowercased()
        
        // Check if the image exists in the assets
        if let _ = UIImage(named: domainImageName) {
            return domainImageName
        } else {
            return "globe" // Fallback image if the domain image is not found
        }
    }
    
    func getDomain(from url: String) -> String? {
        var domain = url.lowercased() // Make sure it's lowercase for uniformity

        // Remove "https://" or "http://"
        if domain.hasPrefix("https://") {
            domain = String(domain.dropFirst(8))
        } else if domain.hasPrefix("http://") {
            domain = String(domain.dropFirst(7))
        }

        // Remove "www." if present
        if domain.hasPrefix("www.") {
            domain = String(domain.dropFirst(4))
        }

        // Remove top-level domain (e.g., .com, .net, .org)
        if let range = domain.range(of: "\\.[a-z]{2,3}(\\.[a-z]{2,3})?$", options: .regularExpression) {
            domain.removeSubrange(range)
        }

        print("Processed Domain: \(domain)")
        return domain.isEmpty ? nil : domain
    }

}

struct PasscodeListView: View {
    
    
    @Query var codes : [Credential]
    @Environment(\.modelContext) var context
    @State private var setupMasterKeyForm = false
    @State private var showAddCredentialForm = false
    @State private var itemToDelete: Credential?
    @State private var showDeletePrompt = false
    
    
    @State var masterKey : String? = nil
    
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
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        
    }
    var body: some View {
        NavigationView {
            VStack {
                if codes.isEmpty {
                    Image(systemName: "figure.climbing")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.secondary)
                    Text("Keep your data safe—don’t let it slip away!")
                        
                }
                else {
                    List {
                        ForEach(codes) { item in
                            
                            NavigationLink(destination: PassCodeDetailView(passCode: item)) {
                                PassCodeCellView(credential: item)
                                    .buttonStyle(.plain)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            itemToDelete = item
                                            showDeletePrompt = true // Set to true without toggling
                                        } label: {
                                            Image(systemName: "xmark.bin")
                                                .renderingMode(.template)
                                        }
                                        .tint(Color.red)
                                    }
                            }
                            .listRowSeparator(.hidden)
                            
                        }
                    }
                    .listStyle(.plain)
                    
                }
            }
            
            
            .alert("Delete Passcode", isPresented: $showDeletePrompt) {
                Button("No", role: .cancel) {
                    itemToDelete = nil
                }
                Button("Yes", role: .destructive) {
                    if let itemToDelete = itemToDelete {
                        invokeDeleteAction(for: itemToDelete)
                    }
                }
            } message: {
                Text("This action cannot be reverted. Continue?")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddCredentialForm.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddCredentialForm) {
//                AddCredentialForm { cred in
//                    addCredential(credential: cred)
//                }
                AddCredentialForm { cred in
                    addCredential(credential: cred)
                }
            }
            .onReceive(NotificationCenter.default
                .publisher(for: NSNotification.Name(MASTER_KEY_UPDATED)), perform: { _ in
//                    fetchCredentials()
            })
            .navigationTitle("Valora")
        }
        
        .onAppear {
            
            if masterKey == nil {
                let val = UserDefaults.standard.value(forKey: APP_MASTER_KEY_SET) as? Bool
                if val != nil {
                    masterKey = AppSecurity.shared.retrieveValueFromKeychain(forKey: APP_MASTER_KEY)
                }
                else {
                    // to handle the case if any previous value was already saved to keychain
                   _ = AppSecurity.shared.deleteValueFromKeychain()
                    setupMasterKeyForm.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $setupMasterKeyForm, content: {
            SetupMasterKeyForm {
                isEditMode,masterKey  in
                _ = AppSecurity.shared.storeValueInKeychain(value: masterKey, forKey: APP_MASTER_KEY)
                UserDefaults.standard.setValue(true, forKey: APP_MASTER_KEY_SET)
            }
        })
    }
    
    private func addCredential(credential : Credential) {
        context.insert(credential)
    }
    
    func invokeDeleteAction(for item: Credential) {
        context.delete(item)
    }

}
