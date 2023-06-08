//
//  AppError.swift
//  GoogleDrive
//
//  Created by Vsevolod on 06.06.2023.
//

import Foundation

enum AppError: LocalizedError, Identifiable, Hashable {
    var id: Self { self }
    
    case general(String)
    
    var errorDescription: String? {
        switch self {
        case let .general(value):
            return value
        }
    }
}

