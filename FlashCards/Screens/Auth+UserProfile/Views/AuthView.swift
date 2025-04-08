//
//  AuthView.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 4.04.25.
//

import SwiftUI
import SwiftData

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isRegistration = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(isRegistration ? "Register" : "Log In")) {
                    
                    if !authViewModel.errorEmail.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                            Text(authViewModel.errorEmail).foregroundStyle(.red)
                        }
                    }
                    TextField("Email", text: $authViewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onSubmit {
                            authViewModel.validateEmail()
                        }
                    
                    if !authViewModel.errorPassword.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                            Text(authViewModel.errorPassword).foregroundStyle(.red)
                        }
                    }
                    SecureField("Password", text: $authViewModel.password)
                        .onSubmit {
                            authViewModel.validatePassword()
                            if isRegistration {
                                authViewModel.validateConfirmPassword()
                            }
                        }
                    
                    if isRegistration {
                        if !authViewModel.errorConfirmPassword.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                                Text(authViewModel.errorConfirmPassword).foregroundStyle(.red)
                            }
                        }
                        SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                            .onSubmit {
                                authViewModel.validateConfirmPassword()
                            }
                    }
                }
                
                Section {
                    Button(isRegistration ? "Create Account" : "Log In") {
                        Task {
                            if isRegistration {
                                await authViewModel.register()
                            } else {
                                await authViewModel.login()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(authViewModel.isLoading)
                }
                
                Section {
                    Button(action: {
                        Task { await authViewModel.signInWithGoogle() }
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Sign in with Google")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(authViewModel.isLoading)
                }
                
                Section {
                    Button(isRegistration ? "Already have an account?" : "Don't have an account?") {
                        withAnimation {
                            isRegistration.toggle()
                            authViewModel.errorEmail = ""
                            authViewModel.errorPassword = ""
                            authViewModel.errorConfirmPassword = ""
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Account")
            .alert(isPresented: $authViewModel.showError) {
                Alert(title: Text("Error"),
                      message: Text(authViewModel.errorMessage ?? "Unknown error"),
                      dismissButton: .default(Text("OK")))
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
