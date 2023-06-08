//
//  AuthorizationService.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import GoogleSignIn

@MainActor
final class AuthorizationService: ObservableObject {
    func handleURL(_ url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func restorePreviousSignIn() async throws -> GIDGoogleUser  {
        try await GIDSignIn.sharedInstance.restorePreviousSignIn()
    }
    
    func signIn(withPresenting presentingViewController: UIViewController) async throws -> GIDGoogleUser {
        let user = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController).user
        
        let additionalScopes = [
            "https://www.googleapis.com/auth/drive"
        ]
        
        if let grantedScopes = user.grantedScopes,
           !grantedScopes.contains(additionalScopes) {
            
            try await user.addScopes(additionalScopes, presenting: presentingViewController)
        }
        
        return user
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    func disconnect() async throws {
        try await GIDSignIn.sharedInstance.disconnect()
    }
}
