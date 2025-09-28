//
//  PostRow.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/18/25.
//

import SwiftUI
import CoreLocation
import ParseSwift

struct PostCard: View {
    let post: Post
    let canSeeFeed: Bool
    @State private var place: String?
    @State private var geoTask: Task<Void, Never>?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .top, spacing: 10) {
                AvatarView(name: post.author?.username ?? "JD")
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author?.username ?? "Jane Doe")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    
                    if let place {
                        Text("\(place), \(timeAgo)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    } else {
                        Text(timeAgo)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
            }

            // Photo
            if let url = post.image?.url {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    ZStack { Color(.systemGray4); ProgressView() }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                .blur(radius: canSeeFeed ? 0 : 18)
                .overlay {
                    if !canSeeFeed {
                        Text("Post to see friends")
                            .font(.headline)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }

            // Caption
            if let c = post.caption, !c.isEmpty {
                Text(c)
                    .font(.body)
                    .foregroundStyle(.white)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: 0.12))
        )
        .task {
            geoTask?.cancel()
            guard place == nil, let gp = post.location else { return }
            let coord = CLLocationCoordinate2D(latitude: gp.latitude, longitude: gp.longitude)
            geoTask = Task {
                if let name = await PlaceFormatter.shared.name(for: coord), !Task.isCancelled {
                    await MainActor.run { place = name }
                }
            }
        }
        .onDisappear { geoTask?.cancel() }
    }

    
    private var timeAgo: String {
        RelativeDateTimeFormatter()
            .localizedString(for: post.createdAt ?? Date(), relativeTo: Date())
            .replacingOccurrences(of: "ago", with: "late")
    }
}

struct AvatarView: View {
    let name: String
    private var initials: String {
        let parts = name.split(separator: "_").flatMap { $0.split(separator: ".") }
        let letters = parts.prefix(2).compactMap { $0.first }.map { String($0).uppercased() }
        return letters.joined().isEmpty ? "JD" : letters.joined()
    }

    var body: some View {
        ZStack {
            Circle().fill(Color(white: 0.25))
            Text(initials)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 28, height: 28)
    }
}
