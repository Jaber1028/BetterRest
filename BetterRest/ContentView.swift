//
//  ContentView.swift
//  BetterRest
//
//  Created by jacob aberasturi on 1/20/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    // Result variables
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    // Default value for waking up
    static var defaultWakeTime: Date {
        var components = DateComponents ()
        components.minute = 30
        components.hour = 10
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("When will you wake up?", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("How long do you want to sleep for?")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("How much coffee will you need?")
                        .font(.headline)
                    
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
                
                Spacer()
            }
            .navigationTitle("BetterSleep")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .padding()
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            // Setup MLmodel
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            // Get our selected date's information in a usable format
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            // Convert to seconds
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        
        catch {
            alertTitle = "Error"
            alertMessage = "Sorry there was a problem with our calculations!"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
