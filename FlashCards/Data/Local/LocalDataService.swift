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
    
    func addCard(_ card: CardModel) throws {
        context.insert(card)
        try context.save()
    }
    
    func deleteCard(_ card: CardModel) throws {
        context.delete(card)
        try context.save()
    }
    
    func deleteAllCards() throws {
        if let allCards = try? context.fetch(FetchDescriptor<CardModel>()) {
            for card in allCards {
                context.delete(card)
            }
            try context.save()
        }
    }
    
    func fetchAllCards() throws -> [CardModel] {
        return try context.fetch(FetchDescriptor<CardModel>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))
    }
}
