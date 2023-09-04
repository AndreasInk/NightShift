//
//  ScheduleView.swift
//  OnCall
//
//  Created by Andreas Ink on 8/25/23.
//

import SwiftUI
import SwiftData
struct ScheduleView: View {
    @State var addSchedule = false
    @State var editProfile = false
    @Query var schedules: [Schedule]
    var schedule: Schedule = Schedule(id: UUID().uuidString, name: "", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 4), autoPick: true, style: .demo)
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            addSchedule = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .fancyScroll()
                        }
                        .sheet(isPresented: $addSchedule) {
                            EditScheduleView(schedule: schedule)
                        }
                        Button {
                            editProfile = true
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .fancyScroll()
                        }
                        .sheet(isPresented: $editProfile) {
                            EditProfileView()
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    ForEach(schedules, id: \.id) { schedule in
                        ScheduleCellView(schedule: schedule)
                    }
                }
            }
            .scrollClipDisabled()
        }
        .onAppear {
            viewModel.syncWithBackend()
        }
    }
}

struct ScheduleCellView: View {
    @State var expand = false
    @State var showEdit = false
    var schedule: Schedule
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                PeopleGridView(people: schedule.peopleOnShift ?? [])
                Text(schedule.name ?? "None")
                    .foregroundStyle(.white)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.bouncy) {
                    expand.toggle()
                }
            }
            .padding()
            if expand {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                        Image(systemName: "pencil")
                            .font(.headline)
                            .foregroundStyle(schedule.style?.color.color ?? .black)
                            .brightness(0.2)
                    }
                    .frame(width: 50, height: 55, alignment: .topTrailing)
                    .onTapGesture {
                        showEdit = true
                    }
                    .sheet(isPresented: $showEdit) {
                        EditScheduleView(schedule: schedule)
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .background {
            ZStack {
                VStack {
                    let isiPad = UIDevice.current.model.lowercased().contains("pad")
                    ForEach(0...10, id: \.self) { _ in
                        HStack {
                            ForEach(0...(isiPad ? 40 : 10), id: \.self) { _ in
                                Text(schedule.style?.emoji ?? "👀")
                                    .opacity(0.15)
                                    .fixedSize()
                            }
                        }
                    }
                }
            }
            .rotationEffect(.degrees(15))
        }
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(schedule.style?.color.color ?? .blue)
        }
        
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        
        .scrollTransition { effect, phase in
            effect
                .blur(radius: phase.isIdentity ? 0 : 10)
                .opacity(phase.isIdentity ? 1 : 0)
                .scaleEffect(phase.isIdentity ? 1 : 0.8)
        }
        
        
    }
}
struct PeopleGridView: View {
    let people: [PersonCodable]
    var body: some View {
        LazyVGrid(columns: [.init(), .init()]) {
            ForEach(people, id: \.name) { person in
                person.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .scaleEffect(0.6)
                    .clipShape(Circle())
                    .padding(3)
                    .background {
                        Circle()
                            .fill(person.color?.color.gradient ?? AnyGradient(.init(colors: [.blue])))
                    }
            }
        }
        .frame(width: 50)
    }
}

