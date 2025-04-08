import Foundation
import SwiftData
import FirebaseAuth

@MainActor
class CardsViewModel: ObservableObject {
    @Published var cards: [CardModel] = []

    @Published var isSyncing: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    var storageMode: StorageMode {
        Auth.auth().currentUser == nil ? .local : .remote
    }

    // Операция и её Task
    private var pendingOperation: (() async throws -> Void)?
    private var pendingTask: Task<Void, Never>?

    init() {
        loadCards()
    }
    
    deinit {
        pendingTask?.cancel()
    }

    func loadCards() {
        cards.removeAll()
        if storageMode == .local {
            loadLocalCards()
        } else {
            setRetryOperation { [weak self] in
                try await self?.loadRemoteCards()
            }
            executePendingOperation()
        }
    }

    private func loadLocalCards() {
        do {
            cards = try LocalDataService.shared.fetchAllCards()
        } catch {
            showErrorWithMessage("Failed to load local cards: \(error.localizedDescription)")
        }
    }

    private func loadRemoteCards() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSyncing = true
        defer { isSyncing = false }

        let fetched = try await FirebaseSyncService.shared.fetchAllFromFirebase(userId: uid)
        cards = fetched
    }

    func addCard(_ card: CardModel) {
        if storageMode == .local {
            addLocalCard(card)
        } else {
            setRetryOperation { [weak self] in
                try await self?.addRemoteCard(card)
            }
            executePendingOperation()
        }
    }

    private func addLocalCard(_ card: CardModel) {
        do {
            try LocalDataService.shared.addCard(card)
            loadLocalCards()
        } catch {
            showErrorWithMessage("Failed to add local card: \(error.localizedDescription)")
        }
    }

    private func addRemoteCard(_ card: CardModel) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSyncing = true
        defer { isSyncing = false }

        try await FirebaseSyncService.shared.addCardToFirebase(userId: uid, card: card)
        let updated = try await FirebaseSyncService.shared.fetchAllFromFirebase(userId: uid)
        cards = updated
    }

    func deleteCards(_ cardsToDelete: [CardModel]) {
        if storageMode == .local {
            deleteLocalCards(cardsToDelete)
        } else {
            setRetryOperation { [weak self] in
                try await self?.deleteRemoteCards(cardsToDelete)
            }
            executePendingOperation()
        }
    }

    private func deleteLocalCards(_ cardsToDelete: [CardModel]) {
        do {
            try LocalDataService.shared.deleteCards(cardsToDelete)
            loadLocalCards()
        } catch {
            showErrorWithMessage("Failed to delete local cards: \(error.localizedDescription)")
        }
    }

    private func deleteRemoteCards(_ cardsToDelete: [CardModel]) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSyncing = true
        defer { isSyncing = false }

        let ids = cardsToDelete.map { $0.id }
        try await FirebaseSyncService.shared.deleteCardsFromFirebase(userId: uid, cardIds: ids)
        let updated = try await FirebaseSyncService.shared.fetchAllFromFirebase(userId: uid)
        cards = updated
    }

    private func setRetryOperation(_ operation: @escaping () async throws -> Void) {
        pendingOperation = operation
    }

    private func executePendingOperation() {
        pendingTask?.cancel()
        pendingTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.pendingOperation?()
                self.pendingOperation = nil
            } catch {
                self.showErrorWithMessage(error.localizedDescription)
            }
        }
    }

    private func showErrorWithMessage(_ message: String) {
        errorMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showError = true
        }
    }

    func retryPendingOperation() {
        executePendingOperation()
    }

    func cancelPendingOperation() {
        pendingTask?.cancel()
        pendingTask = nil
        pendingOperation = nil
    }
}
