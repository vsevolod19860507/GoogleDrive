//
//  DriveVM.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import SwiftUI
import GoogleAPIClientForREST_Drive

@MainActor
final class DriveVM: ObservableObject {
    @Published private(set) var quota: GTLRDrive_About_StorageQuota = GTLRDrive_About_StorageQuota()
    @Published private(set) var files: [GTLRDrive_File] = []
    @Published private(set) var error: Error?
    
    private let driveService: DriveService
    
    init(driveService: DriveService) {
        self.driveService = driveService
    }
    
    func getQuota() async {
        do {
            quota = try await driveService.quota
            
            error = nil
        } catch {
            self.error = error
        }
    }
    
    func getAllFiles() async {
        do {
            files = try await driveService.allFiles
            error = nil
        } catch {
            self.error = error
        }
    }
}
