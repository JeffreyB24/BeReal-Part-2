//
//  PostDetailView.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/26/25.
//

import SwiftUI
import ParseSwift

struct PostDetailView: View {
    let post: Post

    @State private var comments: [Comment] = []
    @State private var text = ""
    @State private var isSending = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            // Show the post at the top
            Section {
                PostCard(post: post, canSeeFeed: true)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

            // Comments thread
            Section(header: Text("Comments")) {
                ForEach(comments, id: \.objectId) { c in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(c.author?.username ?? "unknown")
                            .font(.footnote).bold()
                        Text(c.text ?? "")
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }

                HStack(spacing: 8) {
                    TextField("Add a comment…", text: $text)
                        .textFieldStyle(.roundedBorder)
                    Button(isSending ? "…" : "Send") {
                        Task { await send() }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                }
            }
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .task { await reload() }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    // MARK: - Data

    private func reload() async {
        do {
            comments = try await Comment.query()
                .where("post" == post)
                .include("author")
                .order([.ascending("createdAt")])
                .find()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func send() async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let me = AppUser.current, !isSending else { return }
        isSending = true
        do {
            var c = Comment()
            c.text = trimmed
            c.author = me
            c.post = post
            _ = try await c.save()
            text = ""
            await reload()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }
}
