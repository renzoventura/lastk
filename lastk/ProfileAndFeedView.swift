//
//  ProfileAndFeedView.swift
//  lastk
//
//  Single screen: profile at top, run feed grid below. One scroll.
//

import SwiftUI

struct ProfileAndFeedView: View {
    @Bindable var session: StravaSession
    @Bindable var feedViewModel: RunFeedViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                profileSection
                runsSection
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("LastK")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", action: { session.logout() })
            }
        }
        .task {
            if feedViewModel.runs.isEmpty {
                await feedViewModel.loadFirstPage()
            }
        }
        .navigationDestination(item: $feedViewModel.selectedRunForBackground) { runItem in
            BackgroundSelectionView(runItem: runItem) {
                feedViewModel.selectedRunForBackground = nil
            }
        }
    }

    @ViewBuilder
    private var profileSection: some View {
        if let athlete = session.currentAthlete {
            AthleteContentView(athlete: athlete, onLogOut: { session.logout() })
        } else {
            ProgressView("Loading profile…")
                .frame(maxWidth: .infinity)
                .padding()
        }
    }

    private var runsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Runs")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 8)
            if feedViewModel.runs.isEmpty, feedViewModel.isLoading {
                ProgressView("Loading runs…")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else if feedViewModel.runs.isEmpty, feedViewModel.loadError != nil {
                ContentUnavailableView(
                    "Couldn't load runs",
                    systemImage: "exclamationmark.triangle",
                    description: Text(feedViewModel.loadError ?? "")
                )
                .padding(.vertical, 32)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0)
                ], spacing: 0) {
                    ForEach(feedViewModel.runs) { item in
                        Button {
                            feedViewModel.selectedRunForBackground = item
                        } label: {
                            RunCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    Color.clear
                        .frame(height: 1)
                        .onAppear { feedViewModel.didScrollNearBottom() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileAndFeedView(session: StravaSession(), feedViewModel: RunFeedViewModel(session: StravaSession()))
    }
}
