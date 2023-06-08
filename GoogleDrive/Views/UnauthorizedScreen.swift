//
//  UnauthorizedScreen.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import SwiftUI
import GoogleSignInSwift

struct UnauthorizedScreen: View {
    @EnvironmentObject private var authorizationVM: AuthorizationVM
    
    var body: some View {
        NavigationStack {
            GoogleSignInButton {
                Task {
                    await authorizationVM.signIn()
                }
            }
            .padding()
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UnauthorizedScreen_Previews: PreviewProvider {
    static var previews: some View {
        UnauthorizedScreen()
            .environmentObject(AuthorizationVM(authorizationService: AuthorizationService()))
    }
}
