//
//  StorePhoneNumber.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 5/28/24.
//

import Foundation

class StorePhoneNumber {
    private let phoneNumberKey = "phoneNumber"
    private let userDefaults = UserDefaults.standard

    var isFirstTime: Bool {
        return userDefaults.string(forKey: phoneNumberKey) == nil
    }

    var phoneNumber: String? {
        get {
            return userDefaults.string(forKey: phoneNumberKey)
        }
        set {
            userDefaults.set(newValue, forKey: phoneNumberKey)
        }
    }
}
