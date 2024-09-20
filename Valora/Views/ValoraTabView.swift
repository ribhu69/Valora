//
//  ValoraTabView.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import Foundation
import SwiftUI

struct ValoraTabView : View {
    @State private var animateList = false
    @State private var animateGear = false
    var body: some View {
        
        NavigationStack {
            TabView {
                PasscodeListView()
                
                    .tabItem {
                        
                        Button(action: {
                            animateList.toggle()
                        }, label: {
                            Image(systemName: "list.clipboard")
                                .renderingMode(.template)
                                .symbolEffect(.pulse, value: animateList)
                        })
                         
                    }
                SettingsView()
                    .tabItem {
                        
                        Button(action: {
                            animateGear.toggle()
                            
                        }, label: {
                            Image(systemName: "gear")
                                .renderingMode(.template)
                                .symbolEffect(.pulse, value: animateGear)
                        })
                        
                    }
            }
        }
    }
    
    
}
