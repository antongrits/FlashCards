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
    
    func syncFirestoreToLocal(userId: String, localDataService: LocalDataService) async throws {
        let cardsRef = db.collection("users").document(userId).collection("cards")
        let snapshot = try await cardsRef.getDocuments()
        let remoteCards = snapshot.documents
        
        var cardsToInsert: [CardModel] = []
        
        try await withThrowingTaskGroup(of: (String, String, Data?).self) { group in
            var runningTasks = 0
            
            for doc in remoteCards {
                let data = doc.data()
                guard let word = data["word"] as? String else { continue }
                let cardId = doc.documentID
                
                let imagePath = data["imagePath"] as? String ?? ""
                
                group.addTask { [storage] in
                    var imageData: Data? = nil
                    if !imagePath.isEmpty {
                        let storageRef = storage.reference(withPath: imagePath)
                        imageData = try? await storageRef.data(maxSize: 10 * 1024 * 1024)
                    }
                    return (cardId, word, imageData)
                }
                
                runningTasks += 1
                if runningTasks >= maxConcurrentDownloads {
                    if let (id, word, imageData) = try await group.next() {
                        let card = CardModel(id: id, word: word, imageData: imageData ?? Data())
                        cardsToInsert.append(card)
                    }
                    runningTasks -= 1
                }
            }
            
            for try await (id, word, imageData) in group {
                let card = CardModel(id: id, word: word, imageData: imageData ?? Data())
                cardsToInsert.append(card)
            }
        }
        
        for card in cardsToInsert {
            try localDataService.addCard(card)
        }
    }
    
    func syncLocalToFirestore(userId: String, localDataService: LocalDataService) async throws {
        let cardsRef = db.collection("users").document(userId).collection("cards")
        let snapshot = try await cardsRef.getDocuments()
        let remoteIds = Set(snapshot.documents.map { $0.documentID })
        
        let localCards = try localDataService.fetchAllCards()
        let localIds = Set(localCards.map { $0.id })
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            let idsToDelete = remoteIds.subtracting(localIds)
            for id in idsToDelete {
                group.addTask { [db, storage] in
                    let imagePath = "users/\(userId)/images/\(id).jpg"
                    try await db.collection("users").document(userId).collection("cards").document(id).delete()
                    try? await storage.reference(withPath: imagePath).delete()
                }
            }
            
            for card in localCards where !remoteIds.contains(card.id) {
                group.addTask { [db, storage] in
                    let imagePath = "users/\(userId)/images/\(card.id).jpg"
                    let cardRef = db.collection("users").document(userId).collection("cards").document(card.id)
                    let docData: [String: Any] = [
                        "word": card.word,
                        "imagePath": imagePath
                    ]
                    try await cardRef.setData(docData)
                    
                    if !card.imageData.isEmpty {
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        _ = try await storage.reference(withPath: imagePath).putDataAsync(card.imageData, metadata: metadata)
                    }
                }
            }
            
            try await group.waitForAll()
        }
    }
}
