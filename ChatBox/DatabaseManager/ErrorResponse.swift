//
//  ErrorResponse.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 17/4/2023.
//

import Foundation

enum FriendsServiceError: Error {
    case userNotLoggedIn
    case failedToRetrieveData
}

enum UserServiceError: Error {
    case userNotLoggedIn
    case failedToRetrieveData
}
