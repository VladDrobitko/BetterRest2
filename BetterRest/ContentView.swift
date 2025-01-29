//
//  ContentView.swift
//  BetterRest
//
//  Created by Владислав Дробитько on 29/01/2025.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultwakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultwakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                        DatePicker("Please, select a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily coffe income")
                        .font(.headline)
                    Picker("^[\(coffeeAmount) cups](inflect: true)", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
            }
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Okay") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there is a problem to calculate your bedtime."
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
