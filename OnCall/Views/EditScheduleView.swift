//
//  EditScheduleView.swift
//  OnCall
//
//  Created by Andreas Ink on 8/25/23.
//

import SwiftUI
import SwiftData

struct EditScheduleView: View {
    @Environment(\.modelContext) var model
    @Environment(\.dismiss) var dismiss
    @State var schedule: Schedule
    @State var color = Color.black
    @State var name = ""
    @State var emoji = ""
    @State var peopleOnShift = [PersonCodable]()
    @Query var people: [Person]
    var body: some View {
        Form {
            TextField("Schedule Name", text: $name)
            TextField("Schedule Emoji", text: $emoji)
            
            ColorPicker("Schedule Color", selection: $color)

            ScrollView(.horizontal) {
                HStack {
                    
                    ForEach(people) { person in
                        let isIn = peopleOnShift.map(\.userID).contains(person.person.userID)
                        Button {
                            peopleOnShift.append(person.person)
                        } label: {
                            VStack {
                                person.image
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                Text(person.name ?? "No Name")
                            }
                            .opacity(isIn ? 1 : 0.4)
                            .scaleEffect(isIn ? 1 : 0.6)
                        }
                    }
                }
            }
            Button("Add Schedule") {
                let color = CodableColor.toCodable(color: color.toUIColor())
                schedule.style?.color = color
                schedule.name = name
                schedule.style?.emoji = emoji
                schedule.peopleOnShift = peopleOnShift
                model.insert(schedule)
                dismiss()
            }
        }
        .onAppear {
            name = schedule.name ?? ""
            emoji = schedule.style?.emoji ?? ""
            color = schedule.style?.color.color ?? .black
            peopleOnShift = schedule.peopleOnShift ?? []
        }
    }
}

