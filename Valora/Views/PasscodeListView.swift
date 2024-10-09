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
    
    var body: some View {
        HStack {
            Image(getImage(for: credential.webURL))
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .padding(.leading, 8)
        
            Text(credential.webURL ?? credential.desc)
                .font(.title3)
                .padding(.leading, 8)
                .padding(.trailing, 8)
            Spacer()
        }.padding(.vertical, 8)
            
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
                    fetchCredentials()
            })
            .navigationTitle("Valora")
        }
        
        .onAppear {
            
            fetchCredentials()
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
    
    private func fetchCredentials() {
        let fetchDesc = FetchDescriptor<Credential>()
        do {
            let context = `DatabaseManager`.shared.getModelContext()
            let updatedItems = try context.fetch(fetchDesc)
            passCodes = updatedItems
        }
        catch {
            fatalError()
        }
    }
    
    private func addCredential(credential : Credential) {
        withAnimation {
            let context = DatabaseManager.shared.getModelContext()
            context.insert(credential)
            passCodes.append(credential)
        }
    }
    
    func invokeDeleteAction(for item: Credential) {
        let context = DatabaseManager.shared.getModelContext()
        context.delete(item)
        passCodes.removeAll { $0.uuid.uuidString == item.uuid.uuidString}
    }
    
}

//#Preview {
//    PasscodeListView().modelContainer(for: Credential.self, inMemory: true)
//}
//
