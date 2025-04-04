import SwiftUI
import SwiftData
import FirebaseAuth

struct CardsView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var cardsViewModel: CardsViewModel
    
    @State private var selectionMode = false
    @State private var selectedCards = Set<CardModel>()
    @State private var showDeleteConfirmation = false
    
    init(context: ModelContext) {
        _cardsViewModel = StateObject(wrappedValue: CardsViewModel(context: context))
    }
    
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
                        ForEach(cardsViewModel.cards, id: \.id) { card in
                            cardView(for: card)
                        }
                    }
                    .padding(15)
                }
                .onReceive(CardEventPublisher.shared.cardAdded) { value in
                    if value {
                        cardsViewModel.syncAfterExternalAddition()
                        CardEventPublisher.shared.cardAdded.send(false)
                    }
                }
            }
            .alert("Error", isPresented: $cardsViewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(cardsViewModel.errorMessage)
            }
            .alert("Delete selected cards?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    selectedCards.forEach { card in
                        withAnimation(.spring) {
                            cardsViewModel.deleteCard(card)
                        }
                    }
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
