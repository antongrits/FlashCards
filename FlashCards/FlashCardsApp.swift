//
//  FlashCardsApp.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 2.04.25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct FlashCardsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var viewRouter = ViewRouter()
    @StateObject private var authViewModel = AuthViewModel()
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: CardModel.self)
        } catch {
            fatalError("Failed to create ModelContainer for Card.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(viewRouter)
        .environmentObject(authViewModel)
        .modelContainer(container)
    }
}
