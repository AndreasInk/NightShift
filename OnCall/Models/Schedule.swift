//
//  Schedule.swift
//  OnCall
//
//  Created by Andreas Ink on 9/1/23.
//

import SwiftUI
import SwiftData

@Model
class Schedule {
    init(id: String? = nil, name: String? = nil, peopleOnShift: [PersonCodable]? = nil, startDate: Date? = nil, endDate: Date? = nil, autoPick: Bool? = nil, style: ScheduleStyle? = nil) {
        self.id = id
        self.name = name
        self.peopleOnShift = peopleOnShift
        self.startDate = startDate
        self.endDate = endDate
        self.autoPick = autoPick
        self.style = style
    }
    
    var id: String?
    var name: String?
    
    var peopleOnShift: [PersonCodable]?
    var startDate: Date?
    var endDate: Date?
    var autoPick: Bool?
    var style: ScheduleStyle?
    
}
struct CodableSchedule: Codable {
    var id: String?
    var name: String?
    
    var peopleOnShift: [PersonCodable]?
    var startDate: Date?
    var endDate: Date?
    var autoPick: Bool?
    var style: ScheduleStyle?
}
struct ScheduleStyle: Codable {
    var color: CodableColor
    var emoji: String
    static let demo = ScheduleStyle(color: CodableColor.toCodable(color: .black), emoji: "😴")
}


struct PersonCodable: Codable {
    init(name: String? = nil, color: CodableColor? = nil, imageData: Data? = nil, emoji: String? = nil, userID: String? = nil, pushToken: String? = nil) {
        self.name = name
        self.color = color
        self.imageData = imageData
        self.emoji = emoji
        self.userID = userID
        self.pushToken = pushToken
    }
    var name: String?
    var color: CodableColor?
    var imageData: Data?
    var emoji: String?
    var userID: String?
    var pushToken: String?
    var sleepData: [SleepData]?
    var image: Image {
        Image(uiImage: UIImage(data: imageData ?? Data()) ?? UIImage.add)
    }
}
struct SleepData: Codable {
    var date: Date
    var bloodOxygen: Double
    var heartRate: Double
    var respirationRate: Double
    var decibels: Double
}

@Model
class Person {
    init(name: String? = nil, color: CodableColor? = nil, imageData: Data? = nil, emoji: String? = nil) {
        self.name = name
        self.color = color
        self.imageData = imageData
        self.emoji = emoji
    }
    var name: String?
    var color: CodableColor?
    var imageData: Data?
    var emoji: String?

    var image: Image {
        Image(uiImage: UIImage(data: imageData ?? Data()) ?? UIImage.add)
    }
    @Transient
    var person: PersonCodable {
        PersonCodable(name: name, color: color, imageData: imageData, emoji: emoji)
    }
}
