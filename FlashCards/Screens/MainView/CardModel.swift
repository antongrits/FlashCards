//
//  CardModel.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 2.04.25.
//

import SwiftData
import Foundation

@Model
class CardModel {
    @Attribute(.unique) var id: String
    var word: String
    var imageData: Data
    
    init(id: String = UUID().uuidString, word: String, imageData: Data) {
        self.id = id
        self.word = word
        self.imageData = imageData
    }
}
