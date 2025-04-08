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
import FirebaseFirestore
import FirebaseStorage

enum AuthError: Error {
    case missingRootViewController(message: String)
    case noCurrentUser(message: String)
}

struct AuthResultData {
    let user: User
    let additionalUserInfo: AdditionalUserInfo?
}

@MainActor
final class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    private var credential: AuthCredential?
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
        self.credential = EmailAuthProvider.credential(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
        self.credential = EmailAuthProvider.credential(withEmail: email, password: password)
    }
    
    func signInWithGoogle() async throws -> AuthResultData {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw URLError(.badServerResponse)
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.missingRootViewController(message: "Unable to access root ViewController")
        }
        
        let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        let user = userAuthentication.user
        guard let idToken = user.idToken else {
            throw URLError(.userAuthenticationRequired)
        }
        let accessToken = user.accessToken
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                       accessToken: accessToken.tokenString)
        
        self.credential = credential
        
        let authResult = try await Auth.auth().signIn(with: credential)
        return AuthResultData(user: authResult.user, additionalUserInfo: authResult.additionalUserInfo)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        self.credential = nil
        
        Firestore.firestore().clearPersistence()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser(message: "No user is currently signed in")
        }
        
        do {
            try await user.delete()
        } catch let error as NSError {
            if AuthErrorCode(rawValue: error.code) == .requiresRecentLogin {
                try await reauthenticate()
                try await user.delete()
            } else {
                throw error
            }
        }
        
        try await FirebaseSyncService.shared.deleteUserData(userId: user.uid)
    }
    
    private func reauthenticate() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser(message: "No user is currently signed in")
        }
        guard let credential = credential else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await user.reauthenticate(with: credential)
    }
}
