//
//  CardsViewModel.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 2.04.25.
//

import Foundation
import SwiftData

class CardsViewModel: ObservableObject {
    @Published var cards: [CardModel] = []
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    private var localDataService: LocalDataService

    init(context: ModelContext) {
        self.localDataService = LocalDataService(context: context)
        do {
            cards = try localDataService.fetchAllCards()
        } catch {
            handleError("Failed to load cards", error)
        }
    }

    func addCard(_ card: CardModel) {
        do {
            try localDataService.addCard(card)
            try updateCards()
        } catch {
            handleError("Failed to add card", error)
        }
    }

    func deleteCard(_ card: CardModel) {
        do {
            try localDataService.deleteCard(card)
            try updateCards()
        } catch {
            handleError("Failed to delete card", error)
        }
    }

    func deleteAllCards() {
        do {
            try localDataService.deleteAllCards()
            try updateCards()
        } catch {
            handleError("Failed to clear cards", error)
        }
    }

    private func updateCards() throws {
        cards = try localDataService.fetchAllCards()
    }

    private func handleError(_ contextMessage: String, _ error: Error) {
        errorMessage = "\(contextMessage): \(error.localizedDescription)"
        showError = true
    }
}
