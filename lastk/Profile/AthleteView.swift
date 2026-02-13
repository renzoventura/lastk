//
//  AthleteView.swift
//  lastk
//
//  Displays basic Strava athlete info and a log out button.
//

import SwiftUI

struct AthleteView: View {
    @Bindable var session: StravaSession

    var body: some View {
        Group {
            if let athlete = session.currentAthlete {
                ScrollView {
                    AthleteContentView(athlete: athlete, onLogOut: { session.logout() })
                }
            } else {
                ContentUnavailableView(
                    "Loading profile",
                    systemImage: "person.crop.circle",
                    description: Text("Fetching your Strava profile…")
                )
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", action: { session.logout() })
            }
        }
    }
}

/// Profile content (header, details, log out). Use inside ScrollView or as the top section of a combined screen.
struct AthleteContentView: View {
    let athlete: StravaAthleteSummary
    let onLogOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            profileHeader
            detailsSection
        }
        .padding()
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            AthleteAvatarView(profileURL: athlete.profileMedium ?? athlete.profile)
            VStack(alignment: .leading, spacing: 4) {
                Text(athlete.firstname + " " + athlete.lastname)
                    .bold()
                if athlete.premium == true {
                    Text("Strava Premium")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 12))
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details")
                .font(.headline)
            if let city = athlete.city, !city.isEmpty {
                detailRow(label: "City", value: city)
            }
            if let state = athlete.state, !state.isEmpty {
                detailRow(label: "State", value: state)
            }
            if let country = athlete.country, !country.isEmpty {
                detailRow(label: "Country", value: country)
            }
            detailRow(label: "Athlete ID", value: String(athlete.id))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 12))
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

private struct AthleteAvatarView: View {
    let profileURL: String?

    var body: some View {
        Group {
            if let urlString = profileURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(.secondary)
                    default:
                        ProgressView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(.circle)
    }
}

#Preview {
    NavigationStack {
        AthleteView(session: StravaSession())
    }
}
