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
    var schedule: Schedule
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
            Button("Add Schedule") {
                let color = CodableColor.toCodable(color: color.toUIColor())
                schedule.style?.color = color
                schedule.name = name
                schedule.style?.emoji = emoji
                schedule.peopleOnShift = peopleOnShift
                model.insert(schedule)
                dismiss()
                
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(schedule.peopleOnShift ?? [], id: \.name) { person in
                        Button {
                            if let firstIndex = peopleOnShift.map(\.name).firstIndex(of: person.name) {
                                peopleOnShift.remove(at: firstIndex)
                            }
                        } label: {
                            person.image
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        
                    }
                    ForEach(people) { person in
                        if schedule.peopleOnShift?.map(\.name).firstIndex(of: person.person.name) == nil {
                            Button {
                                peopleOnShift.append(person.person)
                            } label: {
                                person.image
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .opacity(0.4)
                            }
                        }
                    }
                }
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

