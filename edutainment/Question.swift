//
//  Question.swift
//  edutainment
//
//  Created by Peter Salz on 02.07.20.
//  Copyright © 2020 Peter Salz App Development. All rights reserved.
//

import Foundation

struct Question {
    
    let text: String
    let answer: Int
}

struct StoredQuestion {
    
    enum QuestionResult {
        case correct
        case wrong
    }
    
    let question: Question
    let givenAnswer: Int
    let result: QuestionResult
}
