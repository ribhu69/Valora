//
//  ValoraList.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftUI
import SwiftData

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
    
    @Environment(\.modelContext) private var modelContext
    @Query private var passCodes: [Credential] = []

    @State private var showAddCredentialForm = false
    @State private var itemToDelete: Credential?
    @State private var showDeletePrompt = false
    
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
                        }
                    }
                    .listRowSeparator(.hidden)
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
            .navigationTitle("Valora")
        }
    }
    
    private func addCredential(credential : Credential) {
        withAnimation {
            modelContext.insert(credential)
        }
    }
    
    private func removeCredential(credential: Credential) {
        modelContext.delete(credential)
    }

    func invokeDeleteAction(for item: Credential) {
        removeCredential(credential: item)
    }
}

#Preview {
    PasscodeListView().modelContainer(for: Credential.self, inMemory: true)
}

