//
//  SetupMasterKeyForm.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//
import Foundation
import SwiftUI

struct SetupMasterKeyForm: View {
    @State private var password: String = ""
    @State private var reenterPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var isSaveEnabled: Bool = false
    
    var onSave : (String)->Void
    var passwordMatch: Bool {
        password == reenterPassword && !password.isEmpty
    }
    
    init(onSave: @escaping (String)->Void) {
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
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        Text("To enhance your account's security, set up a master key. It will be stored securely, and only you will have access. If you forget the key, it cannot be recovered, and you'll lose access to any protected data or features.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 12)
                        
                        SecureField("Password", text: $password)
                            .secureFieldStyle()
                            .padding()
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        SecureField("Re-enter Password", text: $reenterPassword)
                            .secureFieldStyle()
                            .padding()
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !reenterPassword.isEmpty && !password.isEmpty {
                            HStack(alignment: .center) {
                                Spacer()
                                Image(passwordMatch ? "happy" : "sad", bundle: nil)
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 18, height: 18)
                                    .animation(.easeInOut, value: passwordMatch)
                                
                                Text(passwordMatch ? "Passwords match" : "Passwords do not match")
                                    .foregroundColor(passwordMatch ? .green : .red)
                                    .animation(.easeInOut, value: passwordMatch)
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
                       onSave(password)
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
                .onChange(of: passwordMatch) { match in
                    withAnimation {
                        isSaveEnabled = match
                    }
                }
            }
            .padding(.horizontal, 8)
            .navigationTitle("Setup Master Key")
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

struct PasswordMatchView_Previews: PreviewProvider {
    static var previews: some View {
        SetupMasterKeyForm {
            string in
        }
    }
}
