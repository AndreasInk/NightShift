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
    @AppStorage(Constants.isBackendSyncOn) var isBackendSyncOn = false
    @AppStorage(Constants.isFirstLoad) var isFirstLoad = true
    @AppStorage(Constants.userID) var userID = UUID().uuidString

    @Published var schedules: [CodableSchedule] = []
    @Published var profile: PersonCodable = .init()
    
    func syncWithBackend() {
        let bearer = getBearer()
        if schedules.isEmpty {
            Task {
                profile = try await backendSync.getProfile(token: bearer, userID: userID)
                schedules = try await backendSync.getSchedules(token: bearer, userID: userID)
            }
        } else {
            Task {
                try await backendSync.saveProfile(token: bearer, profile: profile)
                for schedule in schedules {
                    try await backendSync.saveSchedule(token: bearer, schedule: schedule)
                }
            }
        }
    }
    func getBearer() -> String {
        
        return keychain.string(forKey: Constants.bearer) ?? ""
    }
    func saveBearer(_ bearer: String) {
        keychain.set(bearer, forKey: Constants.bearer)
    }
}
