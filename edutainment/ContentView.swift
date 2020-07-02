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
    
    //@State private var locations = ["Beach", "Forest", "Desert"]
    
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
            
            ZStack {
                Group {
                    SettingsView(
                        numberOfQuestions: $numberOfQuestions,
                        maximumMultiplication: $maximumMultiplication,
                        state: $state
                    )
                }.zIndex(state == .settings ? 1 : 0)
                
                Group {
                    GameView(
                        maximumMultiplication: $maximumMultiplication,
                        numberOfQuestions: $numberOfQuestions
                    )
                }.zIndex(state == .game ? 1 : 0)
            }
            .navigationBarTitle(headerForState)
            /*
            List {
                ForEach(locations, id: \.self) { location in
                    Text(location)
                }
            }
            .navigationBarTitle(headerForState)
            .navigationBarItems(trailing: Button(action: {
                self.addRow()
            }) { Image(systemName: "plus")})
            */
        }
    }
    
    /*
    private func addRow() {
        self.locations.insert("New Location", at: 0)
    }
    */
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SettingsView: View {
    
    @Binding var numberOfQuestions: NumberOfQuestions
    @Binding var maximumMultiplication: Int
    @Binding var state: AppState
    
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
                    self.state = .game
                }
            }
        }
    }
}

struct GameView: View {
    
    @State private var allQuestions = [Question(text: "1 x 1", answer: 1), Question(text: "2 x 2", answer: 4)]
    @State private var storedQuestions = [StoredQuestion]()
    @State private var currentQuestion: Int = 0
    @State private var answer: String = ""
    @State private var questionAnswered = false
    
    @Binding var maximumMultiplication: Int
    @Binding var numberOfQuestions: NumberOfQuestions
    
    var numericalAnswer: Int {
        Int(answer) ?? 0
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Question label
                    Section(header: Text("Question \(currentQuestion + 1) of \(allQuestions.count)").font(.headline)) {
                    
                        Text("What is \(allQuestions[currentQuestion].text)?")
                    }
                    
                    Section(header: Text("Answer").font(.headline)) {
                        HStack {
                            TextField("Type your answer here", text: $answer)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                            Button("Submit") {
                                self.hideKeyboard()
                                self.questionAnswered = true
                            }
                            .opacity(answer == "" ? 0.0 : 1.0)
                        }
                    }
                    
                    Section(header: Text("Result").font(.headline)) {
                        
                        VStack {
                            // Correct / Wrong label
                            Text("").font(.headline)
                         
                            Button("Next question") {
                                
                                self.storeAnswer(self.numericalAnswer)
                                self.answer = ""
                                self.questionAnswered = false
                                
                                if self.currentQuestion < self.allQuestions.count - 1 {
                                    self.currentQuestion += 1
                                } else {
                                    // TODO: Game over
                                    // Collect # of correct answers
                                    // Show alert controller with # of correct answers
                                    // Offer to play again or change settings
                                }
                            }
                            .opacity(questionAnswered ? 1.0 : 0.0)
                        }
                    }
                }
            
                VStack {
                    Text("Answered Questions").font(.headline)
                    List(storedQuestions) { question in
                        // System symbol checkmark or Cross
                        Image(systemName: "\(question.result == .correct ? "checkmark.seal.fill" : "xmark.seal.fill")")
                        
                        // Question + answer:
                        // question = answer (correct answer if wrong)
                        Text(self.textForStoredQuestion(question))
                    }
                }
            }
        }
    }
    
    func createMultiplicationTable() -> [Question] {
        // TODO: Implement me
        return []
    }
    
    func storeAnswer(_ answer: Int) {
        
        let question = allQuestions[currentQuestion]
        let result: QuestionResult = question.answer == answer
            ? .correct
            : .wrong
        
        let storedQuestion = StoredQuestion(
            question: question,
            givenAnswer: answer,
            result: result
        )
        storedQuestions.insert(storedQuestion, at: 0)
        print("Number of stored questions: \(storedQuestions.count)")
    }
    
    func numberOfCorrectAnswers() -> Int {
        
        storedQuestions.reduce(0) {
            $0 + ($1.result == .correct ? 1 : 0)
        }
    }
    
    func textForStoredQuestion(_ question: StoredQuestion) -> String {
        
        "\(question.question.text) = \(question.givenAnswer)"
            + "\(question.result == .wrong ? " (\(question.question.answer))" : "")"
    }
}

#if canImport(UIKit)
extension View {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
#endif
