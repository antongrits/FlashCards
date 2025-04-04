//
//  AuthViewModel.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 4.04.25.
//

import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var user: User? = nil
    @Published var isLoading: Bool = false
    
    @Published var errorEmail = ""
    @Published var errorPassword = ""
    @Published var errorConfirmPassword = ""
    
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        user = Auth.auth().currentUser
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        errorEmail = ""
        errorPassword = ""
        errorConfirmPassword = ""
        errorMessage = nil
    }
    
    func validateEmail() {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorEmail = "Email cannot be empty"
        } else if !email.contains("@") || !email.contains(".") {
            errorEmail = "Invalid email address"
        } else {
            errorEmail = ""
        }
    }
    
    func validatePassword() {
        if password.isEmpty {
            errorPassword = "Password cannot be empty"
        } else if password.count < 6 {
            errorPassword = "Password must be at least 6 characters"
        } else {
            errorPassword = ""
        }
    }
    
    func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            errorConfirmPassword = "Please confirm your password"
        } else if confirmPassword != password {
            errorConfirmPassword = "Passwords do not match"
        } else {
            errorConfirmPassword = ""
        }
    }
    
    private func validateFields(isRegistration: Bool) -> Bool {
        validateEmail()
        validatePassword()
        if isRegistration { validateConfirmPassword() }
        
        return errorEmail.isEmpty && errorPassword.isEmpty && (isRegistration ? errorConfirmPassword.isEmpty : true)
    }
    
    func login(localDataService: LocalDataService) async {
        guard validateFields(isRegistration: false) else { return }
        
        isLoading = true
        do {
            try await FirebaseAuthService.shared.signIn(email: email, password: password)
            clearFields()
            try localDataService.deleteAllCards()
            try await FirebaseSyncService.shared.syncFirestoreToLocal(userId: Auth.auth().currentUser!.uid,
                                                                      localDataService: localDataService)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func register(localDataService: LocalDataService) async {
        guard validateFields(isRegistration: true) else { return }
        
        isLoading = true
        do {
            try await FirebaseAuthService.shared.signUp(email: email, password: password)
            clearFields()
            try await FirebaseSyncService.shared.syncLocalToFirestore(userId: Auth.auth().currentUser!.uid,
                                                                      localDataService: localDataService)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func signInWithGoogle(localDataService: LocalDataService) async {
        isLoading = true
        do {
            try await FirebaseAuthService.shared.signInWithGoogle()
            clearFields()
            try localDataService.deleteAllCards()
            try await FirebaseSyncService.shared.syncFirestoreToLocal(userId: Auth.auth().currentUser!.uid,
                                                                      localDataService: localDataService)
        } catch let error as AuthError {
            switch error {
            case .noCurrentUser:
                break
            case .missingRootViewController(let message):
                errorMessage = message
            }
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func signOut(localDataService: LocalDataService) {
        do {
            try FirebaseAuthService.shared.signOut(localDataService: localDataService)
            clearFields()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func deleteAccount() async {
        isLoading = true
        do {
            try await FirebaseAuthService.shared.deleteAccount()
        } catch let error as AuthError {
            switch error {
            case .noCurrentUser(let message):
                errorMessage = message
            case .missingRootViewController:
                break
            }
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}
