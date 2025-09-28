//
//  ContentView.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/16/25.
//

import SwiftUI
import ParseSwift

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isRegister = false
    @State private var errorMessage: String?
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView{
            VStack(spacing: 16) {
                Text("BeReal.")
                    .font(.system(size: 60, weight: .bold))
                    .padding(.bottom, 25)
                    .foregroundColor(.white)
                
                Picker("", selection: $isRegister) {
                    Text("Login").tag(false)
                    Text("Signup").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .colorScheme(.dark)
                .tint(.white)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(isRegister ? "Signup" : "Login") {
                    Task { await authAction() }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundColor(.black)
                .cornerRadius(8)
                
                if let msg = errorMessage {
                    Text(msg)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                NavigationLink("", destination: FeedView(), isActive: $isLoggedIn)
                    .hidden()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
        }
    }
    
    private func authAction() async {
        do {
            if isRegister {
                var user = AppUser()
                user.username = username
                user.password = password
                _ = try await user.signup()
            } else {
                _ = try await AppUser.login(username: username, password: password)
            }
            await MainActor.run {
                isLoggedIn = true
            }
        } catch {
            await MainActor.run {
                errorMessage = "Auth failed: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    ContentView()
}
