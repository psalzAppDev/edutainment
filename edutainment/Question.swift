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
