//
//  CardsViewModel.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 2.04.25.
//

import Foundation
import SwiftData
import FirebaseAuth

@MainActor
class CardsViewModel: ObservableObject {
    @Published var cards: [CardModel] = []
    @Published var isSyncing: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private var localDataService: LocalDataService
    
    init(context: ModelContext) {
        self.localDataService = LocalDataService(context: context)
        loadLocalCards()
    }
    
    func loadLocalCards() {
        do {
            cards = try localDataService.fetchAllCards()
        } catch {
            handleError("Failed to load cards", error)
        }
    }
    
    func deleteCard(_ card: CardModel) {
        isSyncing = true
        do {
            try localDataService.deleteCard(card)
            loadLocalCards()
            if let userId = Auth.auth().currentUser?.uid {
                Task {
                    try await FirebaseSyncService.shared.syncLocalToFirestore(userId: userId, localDataService: localDataService)
                    isSyncing = false
                }
            }
        } catch {
            handleError("Failed to delete card", error)
        }
    }
    
    func syncAfterExternalAddition() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isSyncing = true
        Task {
            do {
                try await FirebaseSyncService.shared.syncLocalToFirestore(userId: userId, localDataService: localDataService)
            } catch {
                handleError("Failed to sync card", error)
            }
            isSyncing = false
        }
    }
    
    private func handleError(_ contextMessage: String, _ error: Error) {
        errorMessage = "\(contextMessage): \(error.localizedDescription)"
        showError = true
    }
}
