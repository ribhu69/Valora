//
//  AddCredentialFormX.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 07/10/24.
//
import SwiftUI
struct AddCredentialForm : View {
    @Environment(\.dismiss) var dismiss
    @State private var url: String = ""
    @State private var desc: String = ""
    @State private var userId: String = ""
    @State private var password: String = ""
    
    @FocusState var urlFocused : Bool
    @FocusState var descFocused : Bool
    @FocusState var userIdFocused : Bool
    @FocusState var passwordFocused : Bool
    var onSave : (Credential)->Void
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ScrollView {
                    HStack {
                        
                        Text("Resource Information")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.leading, 8)
                    }
                    
                    TextField("URL", text: $url) {
                        descFocused = true
                    }
                    .focused($urlFocused)
                        .keyboardType(.URL) // Optional: set keyboard type for URL input
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(urlFocused ? Color.green : Color.gray,
                                        lineWidth: urlFocused ? 1.5 :1)
                        }
                        .padding(.bottom, 8)
                    TextField("Description", text: $desc) {
                        userIdFocused = true
                    }
                    .focused($descFocused)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                            
                                .stroke(descFocused ? Color.green : Color.gray, lineWidth: descFocused ? 1.5 : 1)
                        }.padding(.bottom, 8)
                    
                    HStack {
                        Text("Add Credentials")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.leading, 8)
                    }
                    TextField("User ID", text: $userId) {
                        passwordFocused = true
                    }
                    .focused($userIdFocused)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(userIdFocused ? Color.green : Color.gray, lineWidth: userIdFocused ? 1.5 : 1)
                        }.padding(.bottom, 8)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .focused($passwordFocused)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(passwordFocused ? Color.green : Color.gray, lineWidth: passwordFocused ? 1.5 : 1)
                        }
                }
                .padding(.horizontal, 8)
            }
            .onAppear {
                urlFocused = true
            }
            
            .navigationBarTitle("Add Credential", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        saveCredentials()
                    }, label: {
                        Text("Save")
                            .disabled(userId.isEmpty || password.isEmpty || (desc.isEmpty && url.isEmpty))


                    })
                }
            }
        }
    }
    func saveCredentials() {
        
        do {
            let encryptedUserId = try AppSecurity.shared.encrypt(plainText: userId)
            let encryptedPassWord = try AppSecurity.shared.encrypt(plainText: password)
            let credential = Credential(
                uuid: UUID(),
                webURL: url.isEmpty ? nil : url,
                userId: encryptedUserId,
                password: encryptedPassWord,
                desc: desc
            )
            onSave(credential)
            dismiss()
        }
        catch {
            fatalError()
        }
    }
}
