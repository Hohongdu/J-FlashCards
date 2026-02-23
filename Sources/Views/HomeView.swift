import SwiftUI
import SwiftData

struct HomeView: View {
  @Query(sort: \Word.createdAt, order: .reverse) private var words: [Word]

  var body: some View {
    List {
      Section("오늘") {
        NavigationLink("뜻 퀴즈 시작", destination: MeaningQuizView())
      }

      Section("단어") {
        Text("총 \(words.count)개")
        ForEach(words.prefix(20)) { w in
          VStack(alignment: .leading, spacing: 4) {
            Text("[\(w.level)] \(w.kanji)")
              .font(.headline)
            Text(w.hiragana)
              .foregroundStyle(.secondary)
            Text(w.meaningKo)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .navigationTitle("J-FlashCards")
  }
}
