//
//  FeedView.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/16/25.
//

import SwiftUI
import ParseSwift
import PhotosUI

// MARK: - Header used in the feed
private struct FeedHeader: View {
    var onPost: () -> Void
    var onLogout: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill").imageScale(.large)
                Spacer()
                Text("BeReal.")
                    .font(.title2).bold()
                Spacer()
                Button("Logout", action: onLogout)
                    .font(.callout)
            }
            .foregroundStyle(.white)

            Button {
                onPost()
            } label: {
                Text("Post a Photo")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - The Feed
struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var errorMessage: String?
    @State private var isLoadingMore = false
    @State private var showComposer = false
    @State private var canSeeFeed = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                FeedHeader(
                    onPost: { showComposer = true },
                    onLogout: logout
                )

                List {
                    ForEach(posts, id: \.objectId) { post in
                        if canSeeFeed {
                            NavigationLink {
                                PostDetailView(post: post)
                            } label: {
                                PostCard(post: post, canSeeFeed: true)
                            }
                            .listRowInsets(.init(top: 0, leading: 16, bottom: 12, trailing: 16))
                            .listRowBackground(Color.clear)
                            .onAppear { maybeLoadMore(current: post) }
                        } else {
                            PostCard(post: post, canSeeFeed: false)
                                .listRowInsets(.init(top: 0, leading: 16, bottom: 12, trailing: 16))
                                .listRowBackground(Color.clear)
                                .onAppear { maybeLoadMore(current: post) }
                                .contentShape(Rectangle())
                                .onTapGesture { showComposer = true }
                        }
                    }

                    if isLoadingMore {
                        HStack { Spacer(); ProgressView(); Spacer() }
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await refreshPermission()
                    await loadInitial()
                }
            }
        }
        .sheet(isPresented: $showComposer) {
            NewPostView {
                Task {
                    await refreshPermission()
                    await loadInitial()
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
            .onAppear {
                Task {
                    await refreshPermission()
                    await loadInitial()
                }
            }
        .preferredColorScheme(.dark)
    }

    // MARK: data loading
    private func loadInitial() async {
        do {
            let result = try await Post.query()
                .include("author")
                .order([.descending("createdAt")])
                .limit(10)
                .find()
            await MainActor.run { posts = result }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }

    private func maybeLoadMore(current: Post) {
        guard let last = posts.last,
              current.objectId == last.objectId,
              let lastDate = last.createdAt else { return }
        isLoadingMore = true
        Task {
            do {
                let more = try await Post.query()
                    .include("author")
                    .where("createdAt" < lastDate)
                    .order([.descending("createdAt")])
                    .limit(10)
                    .find()
                await MainActor.run {
                    posts += more
                    isLoadingMore = false
                }
            } catch {
                await MainActor.run { isLoadingMore = false }
            }
        }
    }

    // MARK: logout → back to login screen
    private func logout() {
        Task {
            try? await AppUser.logout()
            BeRealReminder.clear()
            await MainActor.run {
                UIApplication.shared.firstKeyWindow?
                    .rootViewController = UIHostingController(rootView: ContentView())
            }
        }
    }
    
    private func refreshPermission() async {
        let last = AppUser.current?.lastPostedAt
        canSeeFeed = {
            guard let last else { return false }
            return Date().timeIntervalSince(last) < 24*3600
        }()
    }
    
    private func loadInitia() async {
        do{
            let windowStart = windowStartForUser()
            let result = try await Post.query()
                .where("createdAt" >= windowStart)
                .include("author")
                .order([.descending("createdAt")])
                .limit(10)
                .find()
            
            await MainActor.run { posts = result }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
    
    private func windowStartForUser() -> Date {
        let nowWindow = Date().addingTimeInterval(-24*3600)
        if let last = AppUser.current?.lastPostedAt {
            return max(nowWindow, last.addingTimeInterval(-24*3600))
        }
        return nowWindow
    }
}

// keyWindow helper
extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}


#Preview{
    FeedView()
}
