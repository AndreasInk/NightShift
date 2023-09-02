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
    
    func getSchedules(token: String, scheduleID: String) async throws -> [CodableSchedule] {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: baseURL + "get_schedules/\(scheduleID)")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authentication")
        let data = try await session.data(for: request)
        print(String(data: data.0, encoding: .utf8))
        return try decoder.decode([CodableSchedule].self, from: data.0)
    }
    
    func saveSchedule(token: String, schedule: CodableSchedule) async throws {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: baseURL + "save_schedule")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.setValue("Bearer " + token, forHTTPHeaderField: "Authentication")
        let data = try await session.upload(for: request, from: encoder.encode(schedule)).0
        print(String(data: data, encoding: .utf8))
    }
    
    func getProfile(token: String, userID: String) async throws -> PersonCodable {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: baseURL + "get_schedule")!)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.setValue("Bearer " + token, forHTTPHeaderField: "Authentication")
        let data = try await session.data(for: request)
        return try decoder.decode(PersonCodable.self, from: data.0)
    }
    
    func saveProfile(token: String, profile: PersonCodable) async throws {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: baseURL + "save_schedule")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.setValue("Bearer " + token, forHTTPHeaderField: "Authentication")
        let data = try await session.upload(for: request, from: encoder.encode(profile)).0
        print(String(data: data, encoding: .utf8))
    }

    
    enum NetworkError: Error {
        case badURL, requestFailed, unknown
    }

    func login(username: String, password: String) async throws -> TokenResponse {
        let user = User(username: username, password: password)
        let url = URL(string: "http://localhost:8000/token/")
        
        guard let requestUrl = url else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(user)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed
        }
        
        let decoder = JSONDecoder()
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        
        return tokenResponse
    }
}
struct TokenResponse: Codable {
    var access_token: String
    var token_type: String
}
struct User: Codable {
    var username: String
    var password: String

}
