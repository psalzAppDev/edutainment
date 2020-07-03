//
//  Question.swift
//  edutainment
//
//  Created by Peter Salz on 02.07.20.
//  Copyright © 2020 Peter Salz App Development. All rights reserved.
//

import Foundation

enum QuestionResult {
    case correct
    case wrong
}

struct Question {
    
    let text: String
    let answer: Int
}

struct StoredQuestion: Identifiable {
    
    let id = UUID()
    let question: Question
    let givenAnswer: Int
    let result: QuestionResult
}

struct SetOfQuestions {
    
    var questions = [Question]()
    
    mutating func generateQuestions(upTo: Int, for number: NumberOfQuestions) {
        
        let range1 = (1...upTo)
        let range2 = (1...upTo)
        
        var allQuestions = [(Int, Int)]()
        
        for m1 in range1 {
            for m2 in range2 {
                allQuestions.append((m1, m2))
            }
        }
        
        let subset: [(Int, Int)]
        
        switch number {
            
        case .all:
            subset = allQuestions.shuffled()
            
        case .five, .ten, .twenty:
            subset = (0..<number.number).compactMap { _ in
                allQuestions.randomElement()
            }
        }
            
        questions = subset.map { (m1, m2) in
            Question(text: "\(m1) x \(m2)", answer: m1 * m2)
        }
    }
}
