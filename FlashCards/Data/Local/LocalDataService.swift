//
//  LocalDataService.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 2.04.25.
//

import Foundation
import SwiftData

@MainActor
final class LocalDataService {
    static let shared = LocalDataService()
    private var context: ModelContext?
    
    func updateContext(_ context: ModelContext) {
        self.context = context
    }
    
    func addCard(_ card: CardModel) throws {
        guard let context else { return }
        context.insert(card)
        try context.save()
    }
    
    func deleteCards(_ cards: [CardModel]) throws {
        guard let context else { return }
        
        for card in cards {
            context.delete(card)
        }
        try context.save()
    }
    
    func fetchAllCards() throws -> [CardModel] {
        guard let context else { return [] }
        return try context.fetch(FetchDescriptor<CardModel>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))
    }
}
