//
//  FirebaseAuthService.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 3.04.25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

@MainActor
class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw URLError(.badServerResponse)
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.missingRootViewController(message: "Unable to access top ViewController")
        }
        
        let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        let user = userAuthentication.user
        guard let idToken = user.idToken else { throw URLError(.userAuthenticationRequired) }
        let accessToken = user.accessToken
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                       accessToken: accessToken.tokenString)
        
        try await Auth.auth().signIn(with: credential)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser(message: "No user is currently signed in")
        }
        try await user.delete()
    }
}

enum AuthError: Error {
    case missingRootViewController(message: String)
    case noCurrentUser(message: String)
}
