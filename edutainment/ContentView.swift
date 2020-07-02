//
//  ContentView.swift
//  edutainment
//
//  Created by Peter Salz on 01.07.20.
//  Copyright © 2020 Peter Salz App Development. All rights reserved.
//

import SwiftUI

enum AppState {
    
    case settings
    case game
    
    mutating func toggle() {
        switch self {
        case .settings:
            self = .game
        case .game:
            self = .settings
        }
    }
}

enum NumberOfQuestions: CaseIterable {
    
    case five
    case ten
    case twenty
    case all
    
    var number: Int {
        switch self {
        case .five:
            return 5
        case .ten:
            return 10
        case .twenty:
            return 20
        case .all:
            return .max
        }
    }
    
    var string: String {
        switch self {
        case .all:
            return "all"
        default:
            return "\(self.number)"
        }
    }
}

struct ContentView: View {
    
    @State private var state: AppState = .settings
    @State private var maximumMultiplication: Int = 1
    @State private var numberOfQuestions: NumberOfQuestions = .five
    
    var headerForState: String {
        
        switch state {
        case .settings:
            return "Settings"
        case .game:
            return "Multitainment"
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            SettingsView(numberOfQuestions: $numberOfQuestions,
                         maximumMultiplication: $maximumMultiplication)
                .navigationBarTitle(headerForState)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SettingsView: View {
    
    @Binding var numberOfQuestions: NumberOfQuestions
    @Binding var maximumMultiplication: Int
    
    var body: some View {
        Form {
            
            Section(
                header: Text("Multiply up to:").font(.headline)
            ) {
                // Stepper for maximum multiplication table
                Stepper(
                    value: $maximumMultiplication,
                    in: 1...12,
                    step: 1
                ) {
                    Text("\(maximumMultiplication)")
                }
            }
            
            Section(
                header: Text("Number of questions:").font(.headline)
            ) {
                // Segmented picker for #questions
                Picker(
                    selection: $numberOfQuestions,
                    label: Text("")
                ) {
                    ForEach(NumberOfQuestions.allCases, id: \.self) { number in
                        
                        Text(number.string)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Start game button
            HStack {
                Button("Start Game") {
                    // Start game
                }
            }
        }
    }
}

/*
struct GameView: View {
    
    @State private var allQuestions = [Question]()
    @State private var storedQuestions = [StoredQuestion]()
    @State private var currentQuestion: Int? = nil
    
    var body: some View {
        
        VStack {
            
            // Question label
            Text().font(.largeTitle)
        
            // Answer text field with decimal pad
            TextField()
            
            // Correct / Wrong label
            Text().font(.headline)
            
            // List with answered questions
            List {
                // For each of answered questions
                
                // System symbol checkmark or Cross
                Image()
                
                // Question + answer:
                // question = answer (correct answer if wrong)
                Text()
            }
        }
    }
}
*/
