//
//  BankError.swift
//  BankManagerConsoleApp
//
//  Created by 최정민 on 2021/04/27.
//

import Foundation

enum BankError: Error {
    case userInput
}

extension BankError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userInput:
            return "Error : Invalid Input"
        }
    }
}