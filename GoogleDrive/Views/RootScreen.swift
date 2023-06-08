//
//  RootScreen.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import SwiftUI

struct RootScreen: View {
    @StateObject private var authorizationVM = AuthorizationVM(authorizationService: AuthorizationService())
    
    var body: some View {
        VStack {
            switch authorizationVM.state {
            case .unauthorized:
                UnauthorizedScreen()
            case .authorized:
                AuthorizedScreen()
            }
            
            if let error = authorizationVM.error {
                Spacer()
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .environmentObject(authorizationVM)
        .onOpenURL { url in
            authorizationVM.handleURL(url)
        }
        .task {
            await authorizationVM.restorePreviousSignIn()
        }
    }
}

struct RootScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen()
    }
}
