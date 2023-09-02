//
//  ViewModel.swift
//  OnCall
//
//  Created by Andreas Ink on 9/2/23.
//

import SwiftUI

class ViewModel: ObservableObject {
    typealias Constants = NightShiftConstants
    private let backendSync = BackendSyncManager()
    private let keychain = KeychainWrapper(serviceName: Constants.keychainServiceName)

    private let health = HealthManager()
    @AppStorage(Constants.isBackendSyncOn) var isBackendSyncOn = true
    @AppStorage(Constants.isFirstLoad) var isFirstLoad = true
    @AppStorage(Constants.userID) var userID = UUID().uuidString
    
    @AppStorage(Constants.username) var username = ""


    @Published var schedules: [CodableSchedule] = []
    @Published var profile: PersonCodable = .init()
    
    func syncWithBackend() {
        Task {
            if isBackendSyncOn {
                let bearer = try await getBearer(username: username, password: keychain.string(forKey: Constants.password) ?? "")
                if schedules.isEmpty {
                    profile = try await backendSync.getProfile(token: bearer, userID: userID)
                    schedules = try await backendSync.getSchedules(token: bearer, scheduleID: userID)
                } else {
                    let sleepData = try await health.querySleepData(from: Date().addingTimeInterval(-3600), to: Date())
                    profile.sleepData = sleepData
                    try await backendSync.saveProfile(token: bearer, profile: profile)
                    for schedule in schedules {
                        try await backendSync.saveSchedule(token: bearer, schedule: schedule)
                    }
                }
            }
        }
    }
    func getBearer(username: String, password: String) async throws -> String {
        let token = keychain.string(forKey: Constants.bearer) ?? ""
        if token.isEmpty {
            let tokenFromServer = try await backendSync.login(username: username, password: password).access_token
            keychain.set(tokenFromServer, forKey: Constants.bearer)
            return tokenFromServer
        } else {
            return token
        }
    }
    func saveBearer(_ bearer: String) {
        keychain.set(bearer, forKey: Constants.bearer)
    }
}
