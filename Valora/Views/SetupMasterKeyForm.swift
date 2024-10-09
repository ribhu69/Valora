//
//  SetupMasterKeyForm.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//
import Foundation
import SwiftUI
import SwiftData


struct LoadingView: View {
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // Progress indicator
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2) // Enlarge the spinner
        }
    }
}

struct SetupMasterKeyForm: View {
    
    @State private var showUpdatingView = false
    private var existingPassword = ""
    @State private var currentPassword: String = ""
    @State private var password: String = ""
    @State private var reenterPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var isSaveEnabled: Bool = false
    
    var isEditMode = false
    var onSave: (Bool, String) -> Void
    
    
    init(isEditMode: Bool = false, onSave: @escaping (Bool, String) -> Void) {
        self.isEditMode = isEditMode
        
        // UINavigationBar customization
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
        
        self.onSave = onSave
        
        if isEditMode {
            existingPassword = AppSecurity.shared.retrieveValueFromKeychain(forKey: APP_MASTER_KEY)!
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            
                            if !isEditMode {
                                Text("To enhance your account's security, set up a master key. It will be stored securely, and only you will have access. If you forget the key, it cannot be recovered, and you'll lose access to any protected data or features.")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 12)
                                
                            } else {
                                SecureField("Enter Current Password", text: $currentPassword)
                                    .secureFieldStyle()
                                    .padding()
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .onChange(of: currentPassword) {
                                        evaluateSaveButtonState()
                                    }
                                    
                            }
                           
                            SecureField(isEditMode ? "Enter New Password" : "Enter Password", text: $password)
                                .secureFieldStyle()
                                .padding()
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: password) {
                                    evaluateSaveButtonState()
                                }
                            
                            SecureField(isEditMode ? "Re-enter New Password" : "Re-enter Password", text: $reenterPassword)
                                .secureFieldStyle()
                                .padding()
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: reenterPassword) {
                                    evaluateSaveButtonState()
                                }
                            
                            if !reenterPassword.isEmpty && !password.isEmpty {
                                HStack(alignment: .center) {
                                    Spacer()
                                    
                                    if !isEditMode {
                                        Image(password == reenterPassword ? "happy" : "sad", bundle: nil)
                                            .resizable()
                                            .renderingMode(.template)
                                            .frame(width: 18, height: 18)
                                            .animation(.easeInOut, value: password == reenterPassword)
                                        
                                        Text(password == reenterPassword ? "Passwords match" : "Passwords do not match")
                                            .foregroundColor(password == reenterPassword ? .green : .red)
                                            .animation(.easeInOut, value: password == reenterPassword)
                                    }
                                    Spacer()
                                }
                                .padding(.top, 12)
                            }
                        }
                    }
                    .padding(.top, 1)
                    .padding(.horizontal, 8)
                    
                    // Save Button
                    VStack {
                        Button(action: {
                            if isEditMode {
                                showUpdatingView.toggle()
                                updatePasscodeEncryption(newKey: password)
                            }
                            onSave(isEditMode, password)
                            dismiss()
                        }) {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isSaveEnabled ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .disabled(!isSaveEnabled)
                        .animation(.easeInOut, value: isSaveEnabled)
                    }
                    .padding()
                }
                .padding(.horizontal, 8)
                
                if showUpdatingView {
                    LoadingView()
                }
            }
            .navigationTitle(!isEditMode ? "Setup Master Key" : "Update Master Key")
            .toolbar {
                if isEditMode {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }

                    }
                }
            }
        }
    }
    
    // Function to evaluate the state of the Save button
    private func evaluateSaveButtonState() {
        
        if isEditMode {
            let x = (!currentPassword.isEmpty &&
                             currentPassword == existingPassword &&
                             password == reenterPassword &&
                             !password.isEmpty && !reenterPassword.isEmpty &&
                             currentPassword != password)
            print("isEditMode and \(x)")

            isSaveEnabled = x
        }
        else {
            let x = (!password.isEmpty && !reenterPassword.isEmpty && password == reenterPassword)
            print("isEditMode and \(x)")
            isSaveEnabled = x
        }
        
    }
    
    private func updatePasscodeEncryption(newKey: String) {
        let fetchDesc = FetchDescriptor<Credential>()
        do {
            
            let credentials = try context.fetch(fetchDesc)
            for credential in credentials {
                let decryptedId = try AppSecurity.shared.decrypt(encryptedData: credential.userId)
                let decryptedPassCode = try AppSecurity.shared.decrypt(encryptedData: credential.password)
                
                credential.userId = try AppSecurity.shared.encrypt(plainText: decryptedId, withKey: newKey)
                credential.password = try AppSecurity.shared.encrypt(plainText: decryptedPassCode, withKey: newKey)
            }
            try context.save()
            NotificationCenter.default.post(name: NSNotification.Name(MASTER_KEY_UPDATED), object: nil)

        }
        catch {
            fatalError()
        }
    }
}

// SecureFieldStyle Extension
extension SecureField {
    func secureFieldStyle() -> some View {
        self
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}
