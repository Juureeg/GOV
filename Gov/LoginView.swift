//
//  LoginView.swift
//  Gov
//
//  Login screen for user authentication
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var userManager = UserManager.shared
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        ZStack {
            // Background preto
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and Title
                VStack(spacing: 8) {
                    Text("gov.br")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("By Jureg")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 50)
                
                // Login Form
                VStack(spacing: 20) {
                    // Username Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Usuário")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 20)
                            
                            TextField("", text: $username)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .placeholder(when: username.isEmpty) {
                                    Text("Digite seu usuário")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Senha")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 20)
                            
                            if showPassword {
                                TextField("", text: $password)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .placeholder(when: password.isEmpty) {
                                        Text("Digite sua senha")
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                            } else {
                                SecureField("", text: $password)
                                    .foregroundColor(.white)
                                    .placeholder(when: password.isEmpty) {
                                        Text("Digite sua senha")
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                    }
                    
                    // Error Message
                    if let error = userManager.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Login Button
                    Button(action: performLogin) {
                        HStack {
                            if userManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Entrar")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .disabled(userManager.isLoading || username.isEmpty || password.isEmpty)
                    .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                Spacer()
            }
        }
    }
    
    private func performLogin() {
        userManager.login(username: username, password: password) { success in
            if success {
                print("Login successful!")
            }
        }
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    LoginView()
}
