//
//  AddCardViewModel.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 3.04.25.
//

import Foundation
import PhotosUI
import SwiftUI
import SwiftData

@MainActor
class AddCardViewModel: ObservableObject {
    @Published var photosPickerItem: PhotosPickerItem?
    @Published var selectedImageData: Data? = nil
    @Published var word: String = ""
    @Published var errorMessageForImage = ""
    @Published var errorMessageForWord = ""
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private let localDataService: LocalDataService
    
    init(context: ModelContext) {
        self.localDataService = LocalDataService(context: context)
    }
    
    func validateWord() {
        if word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessageForWord = "The word cannot be empty"
        } else {
            errorMessageForWord = ""
        }
    }

    func validateImage() {
        if selectedImageData == nil {
            errorMessageForImage = "Please select an image"
        } else {
            errorMessageForImage = ""
        }
    }
    
    func loadPhoto() async {
        if let photosPickerItem,
           let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
            selectedImageData = data
        } else {
            handleError("Failed to load the selected image")
        }
    }
    
    func addCard() {
        do {
            let card = CardModel(word: word, imageData: selectedImageData!)
            try localDataService.addCard(card)
        } catch {
            handleError("Failed to add card", error)
        }
    }
    
    private func handleError(_ contextMessage: String, _ error: Error? = nil) {
        errorMessage = "\(contextMessage): \(error?.localizedDescription ?? "")"
        showError = true
    }
}
