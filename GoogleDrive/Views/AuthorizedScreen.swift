//
//  AuthorizedScreen.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import SwiftUI
import GoogleSignIn

struct AuthorizedScreen: View {
    @StateObject private var driveVM = DriveVM(driveService: DriveService())
    
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            DriveScreen()
                .tabItem {
                    Label("Drive", systemImage: "doc.fill")
                }
        }
        .environmentObject(driveVM)
    }
}

struct AuthorizedScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizedScreen()
            .environmentObject(AuthorizationVM(authorizationService: AuthorizationService()))
    }
}
