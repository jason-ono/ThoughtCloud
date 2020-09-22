//
//  CloudWord.swift
//  ThoughtCloud
//
//  Created by Jason Ono on 7/27/20.
//  Copyright © 2020 Jason Ono. All rights reserved.
//

import Foundation
import NaturalLanguage

struct CloudWord: Equatable, Comparable{
    
    var word: String
    var numOfTimes: Int
    var wordType: NLTag
    init(_ inWord:String, _ inWordType: NLTag) {
        word = inWord
        numOfTimes = 1
        wordType = inWordType
    }
    mutating func increNumOfTimes(){
        numOfTimes+=1
    }
    
    
    
    func toString()->String{
        let representation: String = "\(self.word) is a \(self.stringTypeRep(wordType: wordType)) and shows up \(self.numOfTimes) times"
        return representation
    }
    func stringTypeRep(wordType: NLTag)->String{
        switch wordType{
        case NLTag.adverb:
            return "adverb"
        case NLTag.adjective:
            return "adjective"
        case NLTag.noun:
            return "noun"
        case NLTag.determiner:
            return "determiner"
        case NLTag.verb:
            return "verb"
        case NLTag.preposition:
            return "preposition"
        case NLTag.pronoun:
            return "pronoun"
        case NLTag.particle:
            return "particle"
        case NLTag.number:
            return "number"
        case NLTag.classifier:
            return "classifier"
        case NLTag.interjection:
            return "preposition"
        default:
            return "undefined"
        }
    }
    
// MARK: - Equitable/Comparable methods
    static func == (lhs: CloudWord, rhs: CloudWord) -> Bool {
        return lhs.word == rhs.word
    }
    static func < (lhs: CloudWord, rhs: CloudWord) -> Bool {
        return lhs.numOfTimes < rhs.numOfTimes
    }
}
