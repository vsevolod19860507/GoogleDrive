//
//  GTLRDrive_File.swift
//  GoogleDrive
//
//  Created by Vsevolod on 08.06.2023.
//

import Foundation
import GoogleAPIClientForREST_Drive

extension GTLRDrive_File: Identifiable {
    public var id: String { identifier ?? "" }
}
