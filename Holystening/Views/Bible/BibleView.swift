import SwiftUI

struct BibleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var chapter = 1
    @State private var verses: [(number: Int, text: String)] = []
    @State private var isLoading = false
    @State private var loadFailed = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if loadFailed {
                    ContentUnavailableView(
                        "Couldn't Load",
                        systemImage: "wifi.slash",
                        description: Text("Check your connection and try again.")
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Chapter \(chapter)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.bibleGold)
                                .padding(.bottom, 24)

                            ForEach(verses, id: \.number) { verse in
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("\(verse.number)")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(AppColors.bibleGold)
                                        .frame(minWidth: 20, alignment: .trailing)

                                    Text(verse.text)
                                        .font(.system(size: 17, design: .serif))
                                        .foregroundStyle(.primary)
                                        .lineSpacing(6)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.bottom, 14)
                            }
                        }
                        .padding(24)

                        Text("King James Version")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 24)
                            .accessibilityIdentifier("bible-version-note")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("bible-close-button")
                }
                ToolbarItem(placement: .principal) {
                    Text("Genesis \(chapter)")
                        .font(.headline)
                        .fontDesign(.serif)
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button {
                        chapter -= 1
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Chapter \(chapter - 1)")
                        }
                        .font(.subheadline.weight(.medium))
                    }
                    .disabled(chapter <= 1)
                    .accessibilityIdentifier("bible-prev-chapter")

                    Spacer()

                    Button {
                        chapter += 1
                    } label: {
                        HStack(spacing: 4) {
                            Text("Chapter \(chapter + 1)")
                            Image(systemName: "chevron.right")
                        }
                        .font(.subheadline.weight(.medium))
                    }
                    .disabled(chapter >= 3)
                    .accessibilityIdentifier("bible-next-chapter")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.bar)
            }
        }
        .task(id: chapter) {
            await fetchChapter()
        }
    }

    private func fetchChapter() async {
        isLoading = true
        loadFailed = false
        verses = []
        do {
            let url = URL(string: "https://bible-api.com/genesis+\(chapter)?translation=kjv")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            verses = response.verses.map {
                (number: $0.verse, text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        } catch {
            loadFailed = true
        }
        isLoading = false
    }
}

private struct APIResponse: Decodable {
    let verses: [APIVerse]
    struct APIVerse: Decodable {
        let verse: Int
        let text: String
    }
}
