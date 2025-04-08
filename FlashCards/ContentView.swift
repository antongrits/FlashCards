//
//  ContentView.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 3.04.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init(modelContext: ModelContext) {
        LocalDataService.shared.updateContext(modelContext)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch viewRouter.currentPage {
                case .cardsView:
                    CardsView()
                case .addCardView:
                    AddCardView()
                case .authView:
                    AuthView()
                case .userProfileView:
                    UserProfileView()
                }
            }
            
            Divider()
            
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        viewRouter.currentPage = .cardsView
                    }
                } label: {
                    VStack {
                        Image(systemName: "square.stack")
                        Text("Cards")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button {
                    withAnimation(.easeInOut) {
                        viewRouter.currentPage = authViewModel.user != nil ? .userProfileView : .authView
                    }
                } label: {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Account")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 10)
            .background(Color.gray.opacity(0.2))
        }
        .onReceive(authViewModel.$user) { user in
            withAnimation(.easeInOut) {
                if viewRouter.currentPage == .authView || viewRouter.currentPage == .userProfileView {
                    viewRouter.currentPage = user != nil ? .userProfileView : .authView
                }
            }
        }
    }
}
