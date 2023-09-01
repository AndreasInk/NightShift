//
//  ContentView.swift
//  OnCall Watch App
//
//  Created by Andreas Ink on 8/22/23.
//

import SwiftUI

struct ContentView: View {
   // let health = HealthManager()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
              //  try await health.requestPermission()
            } catch {}
        }
    }
}

#Preview {
    ContentView()
}
