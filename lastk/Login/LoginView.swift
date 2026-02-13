//
//  LoginView.swift
//  lastk
//
//  Login screen with "Log in with Strava" button.
//

import SwiftUI

struct LoginView: View {
    @Bindable var session: StravaSession

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "figure.run")
                .font(.largeTitle)
                .foregroundStyle(.tint)
            Text("LastK")
                .font(.title)
                .bold()
            Text("Connect your Strava account to get started.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            if let error = session.loginError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            Button("Log in with Strava", systemImage: "link", action: logInWithStrava)
                .buttonStyle(.borderedProminent)
                .disabled(session.isLoading)
            if session.isLoading {
                ProgressView()
            }
            Spacer()
        }
        .padding()
        .onAppear { session.clearLoginError() }
    }

    private func logInWithStrava() {
        session.presentLogin()
    }
}

#Preview {
    LoginView(session: StravaSession())
}
