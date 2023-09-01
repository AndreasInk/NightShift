//
//  ContentView.swift
//  OnCall
//
//  Created by Andreas Ink on 8/22/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var showMoon = false
    @State var showIntro = false
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.gradient)
                .ignoresSafeArea()
            
            VStack(alignment: showIntro ? .leading : .center) {
                if showIntro {
                    ScheduleView()
                }
                Group {
                    Image(systemName: "moon.fill")
                        .imageScale(.large)
                        .foregroundStyle(Color.white.gradient)
                        .symbolEffect(.bounce, options: .repeat(3), value: showMoon)
                        .scaleEffect(showIntro ? 10 : 1)
                        .opacity(showIntro ? 0 : 1)
                    Text("Night Shift")
                        .padding()
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color(white: 1/9))
                        .brightness(2)
                        .saturation(3.0)
                        .opacity(0.8)
                }
                .font(.largeTitle.bold())
            }
            .padding()
            
            .onAppear {
                withAnimation(.bouncy) {
                    showMoon = true
                }
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    withAnimation(.snappy) {
                        showIntro = true
                    }
                }
            }
        }
    }
}
