//
//  UserDefault+Ext.swift
//  OnCall
//
//  Created by Andreas Ink on 8/31/23.
//

import Foundation

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
            let url3 = getDocumentsDirectory().appendingPathComponent(key + ".txt")
            do {
                let input = try String(contentsOf: url3)

                let jsonData = Data(input.utf8)
                do {
                    let decoder = JSONDecoder()

                    do {
                        let result = try decoder.decode(T.self, from: jsonData)

                        return result

                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } catch {}

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
