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
    @State private var setOfQuestions = SetOfQuestions()
    
    var headerForState: String {
        
        switch state {
        case .settings:
            return "Settings"
        case .game:
            return "Multitainment"
        }
    }
    
    var body: some View {
        
        ZStack {
            SettingsView(
                numberOfQuestions: $numberOfQuestions,
                maximumMultiplication: $maximumMultiplication,
                appState: $state,
                allQuestions: $setOfQuestions
            )
            .zIndex(state == .settings ? 1 : 0)
            .opacity(state == .settings ? 1.0 : 0.0)
            
            GameView(
                maximumMultiplication: $maximumMultiplication,
                numberOfQuestions: $numberOfQuestions,
                appState: $state,
                allQuestions: $setOfQuestions
            )
            .zIndex(state == .game ? 1 : 0)
            .opacity(state == .game ? 1.0 : 0.0)
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
    @Binding var appState: AppState
    @Binding var allQuestions: SetOfQuestions
    
    var body: some View {
        NavigationView {
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
            }
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(trailing: Button("Start game") {
                
               self.allQuestions.generateQuestions(
                   upTo: self.maximumMultiplication,
                   for: self.numberOfQuestions
               )
               self.appState = .game
            })
        }
    }
}

struct GameView: View {
    
    @State private var storedQuestions = [StoredQuestion]()
    @State private var currentQuestion: Int = 0
    @State private var answer: String = ""
    @State private var questionAnswered = false
    
    @State private var showAlert = false
    
    @Binding var maximumMultiplication: Int
    @Binding var numberOfQuestions: NumberOfQuestions
    @Binding var appState: AppState
    @Binding var allQuestions: SetOfQuestions
    
    var numericalAnswer: Int {
        Int(answer) ?? -1
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                HStack {
                    Text("Question \(currentQuestion + 1) of \(allQuestions.questions.count): ").font(.headline)
                    
                    Text("What is \(appState != .game ? "Error" : allQuestions.questions[currentQuestion].text)?")
                }
                .padding()
            
                HStack {
                    Text("Answer: ").font(.headline)
                    
                    TextField("Type your answer here", text: $answer)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                
                    Button("Submit") {
                        self.hideKeyboard()
                        self.questionAnswered = true
                    }
                    .opacity(numericalAnswer < 0 ? 0.0 : 1.0)
                }
                .padding()
                
                VStack {
                    
                    // Correct / Wrong label
                    Text(self.handleAnswer(self.numericalAnswer))
                        .font(.headline)
                        .padding()
                    
                    Button("Next question") {
                        
                        self.storeAnswer(self.numericalAnswer)
                        self.answer = ""
                        self.questionAnswered = false
                        
                        if self.currentQuestion < self.allQuestions.questions.count - 1 {
                            self.currentQuestion += 1
                        } else {
                            self.showAlert = true
                        }
                    }
                    .padding(.vertical)
                }
                .opacity(questionAnswered ? 1.0 : 0.0)
            
                VStack {
                    Text("Answered Questions").font(.headline)
                    List(storedQuestions) { question in
                        
                        Image(systemName: "\(question.result == .correct ? "checkmark.seal.fill" : "xmark.seal.fill")")
                        
                        Text(self.textForStoredQuestion(question))
                    }
                }
                .opacity(storedQuestions.isEmpty ? 0.0 : 1.0)
                .padding()
            }
            .alert(isPresented: $showAlert) {

                Alert(
                    title: Text("Game Over"),
                    message: Text("You scored \(self.numberOfCorrectAnswers()) out of \(self.allQuestions.questions.count) questions"),
                    primaryButton: .default(Text("Restart")) {
                        self.cleanUp()
                        self.appState.toggle()
                        self.appState.toggle()
                    },
                    secondaryButton: .cancel(Text("Settings")) {
                        self.cleanUp()
                        self.appState = .settings
                    })
            }
            .navigationBarTitle(Text("Multitainment"))
            .navigationBarItems(trailing: Button("Cancel game") {
                
               self.cleanUp()
               self.appState = .settings
            })
        }
    }
    
    func handleAnswer(_ answer: Int) -> String {

        guard appState == .game else {
            return "Error"
        }
        
        let question = allQuestions.questions[currentQuestion]
        let result: QuestionResult = question.answer == answer
            ? .correct
            : .wrong
        
        switch result {
            
        case .correct:
            return "✅ Correct! \(question.text) = \(answer)"
            
        case .wrong:
            return "❌ Wrong! \(question.text) = \(question.answer), your answer: \(answer)"
        }
    }
    
    func storeAnswer(_ answer: Int) {
        
        let question = allQuestions.questions[currentQuestion]
        let result: QuestionResult = question.answer == answer
            ? .correct
            : .wrong
        
        let storedQuestion = StoredQuestion(
            question: question,
            givenAnswer: answer,
            result: result
        )
        storedQuestions.insert(storedQuestion, at: 0)
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
    
    func cleanUp() {

        self.storedQuestions = []
        self.allQuestions.generateQuestions(
            upTo: self.maximumMultiplication,
            for: self.numberOfQuestions
        )
        self.answer = ""
        self.questionAnswered = false
        self.currentQuestion = 0
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
