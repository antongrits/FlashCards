//
//  FirebaseSyncService.swift
//  FlashCards
//
//  Created by Аnтон Гриц on 4.04.25.
//

import FirebaseFirestore
import FirebaseStorage
import SwiftData
import Firebase

@MainActor
final class FirebaseSyncService {
    static let shared = FirebaseSyncService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private let maxConcurrentDownloads = 4
    
    private func checkInternetConnection() throws {
        if !NetworkMonitor.shared.isConnected {
            throw URLError(.notConnectedToInternet)
        }
    }
    
    func pushLocalDataToFirebase(userId: String) async throws {
        try checkInternetConnection()
        
        let localCards = try LocalDataService.shared.fetchAllCards()
        for card in localCards {
            try await addCardToFirebase(userId: userId, card: card)
        }
    }
    
    func fetchAllFromFirebase(userId: String) async throws -> [CardModel] {
        try checkInternetConnection()
        
        return try await fetchAllCardsFromFirebase(userId: userId)
    }
    
    func fetchAllCardsFromFirebase(userId: String) async throws -> [CardModel] {
        try checkInternetConnection()
        
        let cardsRef = db.collection("users").document(userId).collection("cards")
        let snapshot = try await cardsRef.getDocuments()
        let remoteDocs = snapshot.documents
        
        var resultCards: [CardModel] = []
        resultCards.reserveCapacity(remoteDocs.count)
        
        try await withThrowingTaskGroup(of: (String, String, Data, Date).self) { group in
            var runningTasks = 0
            
            for doc in remoteDocs {
                if !NetworkMonitor.shared.isConnected {
                    throw URLError(.notConnectedToInternet)
                }
                
                let data = doc.data()
                
                let cardId = doc.documentID
                
                guard let word = data["word"] as? String else {
                    throw URLError(.badServerResponse, userInfo: [
                        NSLocalizedDescriptionKey: "Missing 'word' field for document \(cardId)"
                    ])
                }
                
                guard let imagePath = data["imagePath"] as? String else {
                    throw URLError(.badServerResponse, userInfo: [
                        NSLocalizedDescriptionKey: "Missing 'imagePath' for document \(cardId)"
                    ])
                }
                
                guard let timestamp = data["createdAt"] as? Timestamp else {
                    throw URLError(.badServerResponse, userInfo: [
                        NSLocalizedDescriptionKey: "Missing 'createdAt' for document \(cardId)"
                    ])
                }
                let createdAt = timestamp.dateValue()
                
                let added = group.addTaskUnlessCancelled { [storage] in
                    if !NetworkMonitor.shared.isConnected {
                        throw URLError(.notConnectedToInternet)
                    }
                    
                    if imagePath.isEmpty {
                        throw URLError(.badURL, userInfo: [
                            NSLocalizedDescriptionKey: "Empty imagePath for card \(cardId)"
                        ])
                    }
                    
                    let storageRef = storage.reference(withPath: imagePath)
                    let imageData = try await storageRef.data(maxSize: 10 * 1024 * 1024)
                    
                    return (cardId, word, imageData, createdAt)
                }
                
                if !added {
                    break
                }
                
                runningTasks += 1
                if runningTasks >= maxConcurrentDownloads {
                    if let (id, fetchedWord, imgData, createdAt) = try await group.next() {
                        let card = CardModel(
                            id: id,
                            word: fetchedWord,
                            imageData: imgData,
                            createdAt: createdAt
                        )
                        resultCards.append(card)
                    }
                    runningTasks -= 1
                }
            }
            
            for try await (id, fetchedWord, imgData, createdAt) in group {
                let card = CardModel(
                    id: id,
                    word: fetchedWord,
                    imageData: imgData,
                    createdAt: createdAt
                )
                resultCards.append(card)
            }
        }
        
        return resultCards
    }
    
    func addCardToFirebase(userId: String, card: CardModel) async throws {
        try checkInternetConnection()
        
        let cardRef = db.collection("users").document(userId).collection("cards").document(card.id)
        let imagePath = "users/\(userId)/images/\(card.id).jpg"
        
        let docData: [String: Any] = [
            "word": card.word,
            "imagePath": imagePath,
            "createdAt": Timestamp(date: card.createdAt)
        ]
        try await cardRef.setData(docData)
        
        if !card.imageData.isEmpty {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            _ = try await storage.reference(withPath: imagePath)
                .putDataAsync(card.imageData, metadata: metadata)
        }
    }
    
    func deleteCardsFromFirebase(userId: String, cardIds: [String]) async throws {
        try checkInternetConnection()
        
        for cardId in cardIds {
            let cardRef = db.collection("users").document(userId).collection("cards").document(cardId)
            let imagePath = "users/\(userId)/images/\(cardId).jpg"
            
            try await cardRef.delete()
            try? await storage.reference(withPath: imagePath).delete()
        }
    }
    
    func deleteUserData(userId: String) async throws {
        try checkInternetConnection()
        
        let userRef = db.collection("users").document(userId)
        let snapshot = try await userRef.collection("cards").getDocuments()
        
        for doc in snapshot.documents {
            let imagePath = doc.data()["imagePath"] as? String ?? ""
            if !imagePath.isEmpty {
                try? await storage.reference(withPath: imagePath).delete()
            }
        }
        
        for doc in snapshot.documents {
            try await userRef.collection("cards").document(doc.documentID).delete()
        }
        
        try await userRef.delete()
    }
}
