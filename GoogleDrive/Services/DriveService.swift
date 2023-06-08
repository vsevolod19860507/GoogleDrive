//
//  DriveService.swift
//  GoogleDrive
//
//  Created by Vsevolod on 05.06.2023.
//

import GoogleSignIn
import GoogleAPIClientForREST_Drive

@MainActor
final class DriveService: ObservableObject {
    
    private let gtlrDriveService = GTLRDriveService()
    
    private func refreshAuthorizer() async throws {
        guard let user = GIDSignIn.sharedInstance.currentUser else { throw AppError.general("Unauthorized") }
        
        gtlrDriveService.authorizer = try await user.refreshTokensIfNeeded().fetcherAuthorizer
    }
    
    var quota: GTLRDrive_About_StorageQuota {
        get async throws {
            try await refreshAuthorizer()
            
            let query = GTLRDriveQuery_AboutGet.query()
            query.fields = "storageQuota(limit, usage)"
            
            return try await withCheckedThrowingContinuation { continuation in
                gtlrDriveService.executeQuery(query) { _, object, error in
                    if let error {
                        continuation.resume(throwing: error)
                        
                        return
                    }
                    
                    guard let quota = (object as? GTLRDrive_About)?.storageQuota
                    else {
                        continuation.resume(throwing: AppError.general("Cannot convert to GTLRDrive_About"))
                        
                        return
                    }
                    
                    continuation.resume(with: .success(quota))
                }
            }
        }
    }
    
    var allFiles: [GTLRDrive_File] {
        get async throws {
            var drive: GTLRDrive_File {
                get async throws {
                    let query = GTLRDriveQuery_FilesGet.query(withFileId: "root")

                    return try await withCheckedThrowingContinuation { continuation in
                        gtlrDriveService.executeQuery(query) { _, object, error in
                            if let error {
                                continuation.resume(throwing: error)
                                
                                return
                            }
                            
                            guard let file = object as? GTLRDrive_File
                            else {
                                continuation.resume(throwing: AppError.general("Cannot convert to GTLRDrive_File"))
                                
                                return
                            }
                            
                            continuation.resume(with: .success(file))
                        }
                    }
                }
            }
            
            var files: [GTLRDrive_File] {
                get async throws {
                    try await refreshAuthorizer()

                    let query = GTLRDriveQuery_FilesList.query()
                    query.q = "trashed = false and 'me' in owners"
                    query.fields = "files(id, name, parents, iconLink, mimeType)"
                    
                    return try await withCheckedThrowingContinuation { continuation in
                        gtlrDriveService.executeQuery(query) { _, object, error in
                            if let error {
                                continuation.resume(throwing: error)
                                
                                return
                            }
                            
                            guard let files = (object as? GTLRDrive_FileList)?.files
                            else {
                                continuation.resume(throwing: AppError.general("Cannot convert to GTLRDrive_FileList"))
                                
                                return
                            }
          
                            continuation.resume(with: .success(files))
                        }
                    }
                }
            }
            
            try await refreshAuthorizer()
            
            return try await ([drive] + files).sorted { $0.mimeType ?? "" > $1.mimeType ?? "" }
        }
    }
    
  
    
    
    
}
