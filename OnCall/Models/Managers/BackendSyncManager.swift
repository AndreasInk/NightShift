//
//  BackendSyncManager.swift
//  OnCall
//
//  Created by Andreas Ink on 9/2/23.
//

import SwiftUI

class BackendSyncManager {
    let baseURL = "/api/"
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    init() {
        decoder.dateDecodingStrategy = .secondsSince1970
        encoder.dateEncodingStrategy = .secondsSince1970
    }
    
    func getSchedules(token: String, userID: String) async throws -> [CodableSchedule] {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: baseURL + "get_schedule")!)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authentication")
        let data = try await session.data(for: request)
        return try decoder.decode([CodableSchedule].self, from: data.0)
    }
    func saveSchedule(token: String, schedule: CodableSchedule) async throws {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: baseURL + "save_schedule")!)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authentication")
        let data = try await session.upload(for: request, from: encoder.encode(schedule)).0
        print(String(data: data, encoding: .utf8))
    }
    
    func getProfile(token: String, userID: String) async throws -> PersonCodable {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: baseURL + "get_schedule")!)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authentication")
        let data = try await session.data(for: request)
        return try decoder.decode(PersonCodable.self, from: data.0)
    }
    func saveProfile(token: String, profile: PersonCodable) async throws {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: baseURL + "save_schedule")!)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authentication")
        let data = try await session.upload(for: request, from: encoder.encode(profile)).0
        print(String(data: data, encoding: .utf8))
    }
}
