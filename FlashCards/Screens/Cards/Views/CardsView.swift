import SwiftUI
import SwiftData
import FirebaseAuth

struct CardsView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var cardsViewModel = CardsViewModel()
    
    @State private var selectionMode = false
    @State private var selectedCards = Set<CardModel>()
    @State private var showDeleteConfirmation = false
    
    private func cardView(for card: CardModel) -> some View {
        CardView(card: card, selectionMode: $selectionMode)
            .overlay {
                if selectionMode {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(selectedCards.contains(card) ? Color.red : Color.blue, lineWidth: 3)
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
                if selectionMode {
                    if selectedCards.contains(card) {
                        selectedCards.remove(card)
                    } else {
                        selectedCards.insert(card)
                    }
                }
            })
            .onLongPressGesture {
                selectionMode = true
                selectedCards.insert(card)
            }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                ScrollView {
                    if cardsViewModel.isSyncing {
                        ProgressView("Syncing...")
                            .padding()
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: isLandscape ? 3 : 2)) {
                        ForEach(cardsViewModel.cards.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { card in
                            cardView(for: card)
                        }
                    }
                    .padding(15)
                }
                .onReceive(CardEventPublisher.shared.cardAdded) { newCard in
                    if let newCard {
                        cardsViewModel.addCard(newCard)
                        CardEventPublisher.shared.cardAdded.send(nil)
                    }
                }
            }
            .alert("Error", isPresented: $cardsViewModel.showError) {
                Button("Try Again") {
                    cardsViewModel.retryPendingOperation()
                }
                Button("Cancel", role: .cancel) {
                    cardsViewModel.cancelPendingOperation()
                }
            } message: {
                Text(cardsViewModel.errorMessage)
            }
            .alert("Delete selected cards?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    cardsViewModel.deleteCards(Array(selectedCards))
                    selectedCards.removeAll()
                    selectionMode = false
                }
                Button("Cancel", role: .cancel) {}
            }
            .navigationTitle("Flash Cards")
            .toolbar {
                if !selectionMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation(.easeInOut) {
                                viewRouter.currentPage = .addCardView
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") {
                            selectedCards.removeAll()
                            selectionMode = false
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Delete") {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
        }
    }
}
