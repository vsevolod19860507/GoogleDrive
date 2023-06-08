//
//  DriveScreen.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import SwiftUI
import GoogleAPIClientForREST_Drive

struct DriveScreen: View {
    @EnvironmentObject private var authorizationVM: AuthorizationVM
    @EnvironmentObject private var driveVM: DriveVM
    
    var body: some View {
        NavigationStack {
            VStack {
                let driveID = driveVM.files.first { $0.parents == nil }?.id ?? ""
                DriveList(currentFileID: driveID)
                    .navigationDestination(for: String.self) { id in
                        DriveList(currentFileID: id)
                    }
                
                if let error = driveVM.error {
                    Spacer()
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .toolbar {
                Menu {
                    Button(role: .destructive) {
                        authorizationVM.signOut()
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.forward")
                    }
                    Button(role: .destructive) {
                        Task {
                            await authorizationVM.disconnect()
                        }
                    } label: {
                        Label("Disconnect", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await driveVM.getAllFiles()
        }
    }
}

struct DriveScreen_Previews: PreviewProvider {
    static var previews: some View {
        DriveScreen()
            .environmentObject(AuthorizationVM(authorizationService: AuthorizationService()))
            .environmentObject(DriveVM(driveService: DriveService()))
    }
}

struct DriveList: View {
    @EnvironmentObject private var driveVM: DriveVM
    
    let currentFileID: String
    
    var body: some View {
        List(driveVM.files.filter { $0.parents?.contains(currentFileID) ?? false }) { file in
            if file.mimeType == "application/vnd.google-apps.folder" {
                NavigationLink(value: file.id) {
                    DriveListRow(file: file)
                }
            } else {
                DriveListRow(file: file)
            }
        }
        .navigationTitle(driveVM.files.first { $0.id == currentFileID }?.name ?? "")
        .refreshable {
            await driveVM.getAllFiles()
        }
    }
}

struct DriveList_Previews: PreviewProvider {
    static var previews: some View {
        DriveList(currentFileID: "1")
            .environmentObject(DriveVM(driveService: DriveService()))
    }
}

struct DriveListRow: View {
    @EnvironmentObject private var driveVM: DriveVM
    
    let file: GTLRDrive_File
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: file.iconLink ?? ""))
            
            VStack(alignment: .leading) {
                Text(file.name ?? "")
                if file.mimeType == "application/vnd.google-apps.folder" {
                    let children = driveVM.files.filter { $0.parents?.contains(file.id) ?? false }
                    let childrenFolderCount = children.filter { $0.mimeType == "application/vnd.google-apps.folder" }.count
                    HStack {
                        Text("^[\(childrenFolderCount) folder](inflect: true)")
                        Text("^[\(childrenFolderCount - children.count) file](inflect: true)")
                    }
                } else {
                    let fileSize = Measurement(value: file.size?.doubleValue ?? 0, unit: UnitInformationStorage.bytes).formatted(.byteCount(style: .memory))
                    let modifiedDate = (file.modifiedTime?.date ?? Date.now).formatted(date: .numeric, time: .omitted)
                    Text("\(fileSize) • \(modifiedDate)")
                }
            }
        }
        
    }
}

struct DriveListRow_Previews: PreviewProvider {
    static var previews: some View {
        DriveListRow(file: GTLRDrive_File())
            .environmentObject(DriveVM(driveService: DriveService()))
    }
}
