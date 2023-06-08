//
//  AuthorizationVM.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import SwiftUI
import GoogleSignIn

@MainActor
final class AuthorizationVM: ObservableObject {
    @Published private(set) var state: AuthorizationState = .unauthorized
    @Published private(set) var user: GIDGoogleUser = GIDGoogleUser()
    @Published private(set) var error: Error?
    
    private let authorizationService: AuthorizationService
    
    init(authorizationService: AuthorizationService) {
        self.authorizationService = authorizationService
    }
    
    func handleURL(_ url: URL) {
        authorizationService.handleURL(url)
    }
    
    func restorePreviousSignIn() async {
        do {
            user = try await authorizationService.restorePreviousSignIn()
            state = .authorized
            error = nil
        } catch GIDSignInError.hasNoAuthInKeychain {
            state = .unauthorized
        } catch {
            self.error = error
            state = .unauthorized
        }
    }
    
    func signIn() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            state = .unauthorized
            
            return
        }
        
        do {
            user = try await authorizationService.signIn(withPresenting: rootViewController)
            state = .authorized
            error = nil
        } catch GIDSignInError.canceled {
            authorizationService.signOut()
            state = .unauthorized
        } catch {
            authorizationService.signOut()
            self.error = error
            state = .unauthorized
        }
    }
    
    func signOut() {
        authorizationService.signOut()
        
        state = .unauthorized
        error = nil
    }
    
    func disconnect() async {
        do {
            try await authorizationService.disconnect()
            state = .unauthorized
            error = nil
        } catch {
            self.error = error
        }
    }
}
