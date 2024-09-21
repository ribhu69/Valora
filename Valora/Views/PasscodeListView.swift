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

struct PassCodeCellView : View {
    var credential : Credential
    var body: some View {
        HStack {
            if credential.webURL != nil {
                Image(systemName: "globe")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.secondary)
                    .frame(width: 18, height: 18)
                    .padding(.leading, 8)
            }
            else {
                Image(systemName: "doc.text")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.secondary)
                    .frame(width: 18, height: 18)
                    .padding(.leading, 8)
            }
         
            Text(credential.webURL ?? credential.desc)
                .font(.title3)
                .padding(.leading, 8)
                .padding(.trailing, 8)
            Spacer()
        }
        .padding(.vertical, 8)
       
        
    }
}

struct PasscodeListView: View {
    
    
    @State var passCodes: [Credential] = []

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
        
        fetchCredentials()
        
    }
    var body: some View {
        NavigationView {
            VStack {
                if passCodes.isEmpty {
                    Image(systemName: "figure.climbing")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.secondary)
                    Text("Keep your data safe—don’t let it slip away!")
                        
                }
                else {
                    List {
                        ForEach(passCodes) { item in
                            
                            NavigationLink(destination: PassCodeDetailView(passCode: item)) {
                                PassCodeCellView(credential: item)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 8)
                                   

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
            let context = DatabaseManager.shared.getModelContext()
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
