//
//  UserProfileView.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 4.04.25.
//

import SwiftUI
import SwiftData

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var confirmDeletion = false
    
    private let localDataService: LocalDataService
    
    init(context: ModelContext) {
        localDataService = LocalDataService(context: context)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Logged in as")) {
                    Text(authViewModel.user?.email ?? "Unknown User")
                        .font(.headline)
                }

                Section {
                    Button("Sign Out") {
                        authViewModel.signOut(localDataService: localDataService)
                    }

                    Button("Delete Account") {
                        confirmDeletion = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
            .alert(isPresented: $authViewModel.showError) {
                Alert(title: Text("Error"),
                      message: Text(authViewModel.errorMessage ?? "Unknown error"),
                      dismissButton: .default(Text("OK")))
            }
            .alert("Delete Account", isPresented: $confirmDeletion) {
                Button("Delete", role: .destructive) {
                    Task { await authViewModel.deleteAccount() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action is irreversible. Do you really want to delete your account?")
            }
            .overlay(
                Group {
                    if authViewModel.isLoading {
                        ZStack {
                            Color.black.opacity(0.3).ignoresSafeArea(.all)
                            ProgressView().scaleEffect(1.5)
                        }
                    }
                }
            )
        }
    }
}
