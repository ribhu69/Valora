//
//  AddCredentialForm.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftUI

import SwiftUI

struct AddCredentialForm: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var url: String = ""
    @State private var desc: String = ""
    @State private var userId: String = ""
    @State private var password: String = ""
    
    var onSave : (Credential)->Void

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Resource Information")) {
                        TextField("URL", text: $url)
                            .keyboardType(.URL) // Optional: set keyboard type for URL input
                        TextField("Description", text: $desc)
                        
                    }
                    Section(header: Text("Add Credentials")) {
                        TextField("User ID", text: $userId)
                        SecureField("Password", text: $password)
                    }
                }
                .navigationBarTitle("Add Credential", displayMode: .inline)
            }
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
        let credential = Credential(
            uuid: UUID(),
            webURL: url.isEmpty ? nil : url,
            userId: userId,
            password: password,
            desc: desc
        )
        onSave(credential)
        dismiss()
    }
}

struct AddCredentialForm_Previews: PreviewProvider {
    static var previews: some View {
        AddCredentialForm {_ in 
            
        }
    }
}
