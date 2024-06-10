//
//  ContentView.swift
//  BetterRest
//
//  Created by Tristin Smith on 6/7/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var calcBedTime: String {
        let message: String
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            message = "Your ideal bedtime is..." + sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            message = "Error! Sorry, there was a problem calculating your bedtime."
        }
        
        return message
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    Picker("Cup(s) of Coffee", selection: $coffeeAmount) {
                        ForEach(0..<21){
                            Text("\($0)")
                        }
                    }
                }
                Section("Recommended Bedtime") {
                    Text(calcBedTime)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

#Preview {
    ContentView()
}
