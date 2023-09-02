//
//  Keychain+Ext.swift
//  OnCall
//
//  Created by Andreas Ink on 9/2/23.
//

import SwiftUI

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            
            return defaultValue
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                if let json = String(data: encoded, encoding: .utf8) {
                    do {
                        let url = getDocumentsDirectory().appendingPathComponent(key + ".txt")
                        try json.write(to: url, atomically: false, encoding: String.Encoding.utf8)

                    } catch {
                        print("erorr")
                    }
                }
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}
