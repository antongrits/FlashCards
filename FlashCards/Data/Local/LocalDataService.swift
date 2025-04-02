//
//  LocalDataService.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 2.04.25.
//

import Foundation
import SwiftData

struct LocalDataService {
    let context: ModelContext
    
    func addCard(word: String, imageData: Data) throws -> CardModel {
        let newCard = CardModel(word: word, imageData: imageData)
        context.insert(newCard)
        try context.save()
        return newCard
    }
    
    func deleteAllCards() throws {
        let fetchDescriptor = FetchDescriptor<CardModel>()
        if let allCards = try? context.fetch(fetchDescriptor) {
            for card in allCards {
                context.delete(card)
            }
            try context.save()
        }
    }
}
