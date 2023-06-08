//
//  HomeScreen.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var authorizationVM: AuthorizationVM
    @EnvironmentObject private var driveVM: DriveVM
    
    var body: some View {
        NavigationStack {
            VStack {
                let usedStorage =  Measurement(value: driveVM.quota.usage?.doubleValue ?? 0, unit: UnitInformationStorage.bytes)
                let totalStorage =  Measurement(value: driveVM.quota.limit?.doubleValue ?? 0, unit: UnitInformationStorage.bytes)
                let text = "Used: \(usedStorage.formatted(.byteCount(style: .memory))) of \(totalStorage.formatted(.byteCount(style: .memory)))"
                ProgressView(text, value: usedStorage.value, total: totalStorage.value)
                    .padding()
                
                Group {
                    Button("Sign out", role: .destructive) {
                        authorizationVM.signOut()
                    }
                    Button("Disconnect", role: .destructive) {
                        Task {
                            await authorizationVM.disconnect()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                if let error = driveVM.error {
                    Spacer()
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .navigationTitle(authorizationVM.user.profile?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await driveVM.getQuota()
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environmentObject(AuthorizationVM(authorizationService: AuthorizationService()))
            .environmentObject(DriveVM(driveService: DriveService()))
    }
}
