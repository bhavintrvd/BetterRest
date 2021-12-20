//
//  ContentView.swift
//  BetterRest
//
//  Created by Bhavin Trivedi on 12/16/21.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var recommendedSleepTime = ""
    @State private var showingAlert = false
    
    static private var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }

    @State private var wakeUp =  defaultWakeTime
    
    init() {
        // calculate initial bed time
        calculateBedtime()
    }
    
    var body: some View {
        NavigationView {
            Form {
                timeSection()
                sleepHoursSection()
                coffeeAmountSection()
                recommendedSleepSection()
            }
            .foregroundColor(.red)
            .navigationTitle("BetterRest")
        }
    }
    
    /// Builds coffee amount section
    /// - Returns: view
    @ViewBuilder func recommendedSleepSection() -> some View {
        Section {
            Text("\(recommendedSleepTime)")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
        } header: {
            Text("Recommended Bed Time")
                .font(.headline)
        }
    }
    
    /// Builds coffee amount section
    /// - Returns: view
    @ViewBuilder func coffeeAmountSection() -> some View {
        Section(content: {
            Picker("Number of Cups", selection: $coffeeAmount) {
                ForEach(1...20, id: \.self) { num in
                    Text("\(num)")
                }
            }
        }, header: {
            Text("Daily coffee intake")
                .font(.headline)
        })
    }
    
    /// Builds time section
    /// - Returns: view
    @ViewBuilder func sleepHoursSection() -> some View {
        Section(content: {
            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25) { changed in
                if changed {
                   calculateBedtime()
                }
            }
        }, header: {
            Text("Desired amount of sleep")
                .font(.headline)
        })
    }
    
    /// Builds time section
    /// - Returns: view
    @ViewBuilder func timeSection() -> some View {
        Section(content: {
            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                .onChange(of: wakeUp, perform: { newValue in
                    calculateBedtime()
                })
                .onAppear(perform: {
                    print("Date picker appeared")
                    calculateBedtime()
                })
                .colorInvert()
                .colorMultiply(.red)
                .labelsHidden()
        }, header: {
            Text("When do you want to wake up?")
                .font(.headline)
        })
    }
    
    /// Calculates bed time
    /// - Returns: string
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            recommendedSleepTime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            recommendedSleepTime = "Sorry, there was a problem calculating your bedtime."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
