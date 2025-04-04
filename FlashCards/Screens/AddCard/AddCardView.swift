//
//  AddCardView.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 3.04.25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct AddCardView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject private var addCardViewModel: AddCardViewModel
    
    init(context: ModelContext) {
        _addCardViewModel = StateObject(wrappedValue: AddCardViewModel(context: context))
    }
    
    private func cardImage(imageData: Data?) -> some View {
        Image(uiImage: imageData != nil ? UIImage(data: imageData!)! : UIImage(systemName: "photo")!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 250, height: 250)
            .padding(20)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Image") {
                    if addCardViewModel.errorMessageForImage != "" {
                        HStack {
                            Image(systemName: "exclamationmark.warninglight.fill")
                                .foregroundStyle(.red)
                            Text(addCardViewModel.errorMessageForImage)
                        }
                    }
                    
                    let imageData = addCardViewModel.selectedImageData
                    
                    PhotosPicker(selection: $addCardViewModel.photosPickerItem, matching: .any(of: [.images, .screenshots])) {
                        cardImage(imageData: imageData)
                            .frame(maxWidth: .infinity)
                    }
                    .onChange(of: addCardViewModel.photosPickerItem) { _, _ in
                        Task {
                            await addCardViewModel.loadPhoto()
                            addCardViewModel.validateImage()
                        }
                    }
                }
                
                Section("Word") {
                    if addCardViewModel.errorMessageForWord != "" {
                        HStack {
                            Image(systemName: "exclamationmark.warninglight.fill")
                                .foregroundStyle(.red)
                            Text(addCardViewModel.errorMessageForWord)
                        }
                    }
                    
                    TextField("Enter the word", text: $addCardViewModel.word)
                        .autocorrectionDisabled()
                        .onSubmit {
                            addCardViewModel.validateWord()
                        }
                }
            }
            .navigationTitle("Add New Flash Card")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $addCardViewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(addCardViewModel.errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        addCardViewModel.validateWord()
                        addCardViewModel.validateImage()
                        if addCardViewModel.errorMessageForWord != "" || addCardViewModel.errorMessageForImage != "" {
                            return
                        }
                        
                        addCardViewModel.addCard()
                        withAnimation(.easeInOut) {
                            viewRouter.currentPage = .cardsView
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        withAnimation(.easeInOut) {
                            viewRouter.currentPage = .cardsView
                        }
                    }
                }
            }
        }
    }
    
}
