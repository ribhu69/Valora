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
    
    private var id: Data
    private var password: Data
    @State private var showPassword: Bool = false
    @State private var url: String = ""
    @State private var description: String
    @State private var flipped = false
    @State var decryptedId : String = ""
    @State var decryptedPassword : String = ""
    @Environment(\.colorScheme) var colorScheme

    
    init(passCode: Credential) {
        id = passCode.userId
        password = passCode.password
        _url = State(wrappedValue: passCode.webURL)
        _description = State(wrappedValue: passCode.desc != nil ? passCode.desc! : "No Description")
        
        _decryptedId = try! State(wrappedValue: AppSecurity.shared.decrypt(encryptedData: passCode.userId))
        _decryptedPassword = try! State(wrappedValue: AppSecurity.shared.decrypt(encryptedData: passCode.password))
    }
   
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // ID Field
                
                Text("User ID")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                TextField("ID", text: $decryptedId)
                    .font(.title2)
                    .padding(.bottom, 8)

                Text("Password")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                HStack {
                    if showPassword {
                        TextField("Password", text: $decryptedPassword)
                            .font(.title2)
                    } else {
                        SecureField("Password", text: $decryptedPassword)
                            .font(.title2)
                    }
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showPassword.toggle()
                            flipped.toggle() // Trigger the flip animation
                        }
                    }) {
                        Image(showPassword ? "hide" : "show", bundle: nil)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.primary)
                           
                            .frame(width: 24, height: 24)
                            .rotation3DEffect(
                                .degrees(flipped ? 0 : 180), // Reverse flip logic: from 180 to 0
                                axis: (x: 1.0, y: 0.0, z: 0.0) // Flip vertically on the x-axis
                            )
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
                        .disabled(true)

                    Button(action: {
                        generateHapticFeedback()
                        UIPasteboard.general.string = url
                    }, label: {
                        Image("copyLink", bundle: nil)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    })
                    .disabled(url.isEmpty)
                }
                .padding(.bottom, 8)
             
                Text("Description")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                TextField("Description", text: $description)
                    .font(.title3)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }
            .padding()
        }
        .navigationBarTitle("Passcode Details", displayMode: .inline)
    }
    
    func generateHapticFeedback() {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    
}

//struct PassCodeDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PassCodeDetailView()
//    }
//}
