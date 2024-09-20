//
//  PassCodeDetailView.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftUI

import SwiftUI

struct PassCodeDetailView: View {
    
    @State private var id: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var url: String = ""
    @State private var description: String = ""

    
    init(passCode: Credential) {
        _id = State(wrappedValue: passCode.userId)
        _password = State(wrappedValue: passCode.password)
        _url = State(wrappedValue: passCode.webURL ?? "")
        _description = State(wrappedValue: passCode.desc)
    }
   
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // ID Field
                
                Text("User ID")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                TextField("ID", text: $id)
                    .font(.title2)
                    .padding(.bottom, 8)

                Text("Password")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                HStack {
                    if showPassword {
                        TextField("Password", text: $password)
                            .font(.title2)
                    } else {
                        SecureField("Password", text: $password)
                            .font(.title2)
                    }
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .renderingMode(.template)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.bottom, 8)

                Text("URL")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                HStack {
                    TextField("URL", text: $url)
                        .font(.title2)

                    Image(systemName: "doc.on.doc.fill")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.secondary)

                }
                .padding(.bottom, 8)
             
                Text("Description")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                TextField("Description", text: $description)
                    .font(.title3)
            }
            .padding()
        }
        .navigationBarTitle("Passcode Details", displayMode: .inline)
    }
}

//struct PassCodeDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PassCodeDetailView()
//    }
//}
