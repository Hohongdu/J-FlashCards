import SwiftUI
import SwiftData

struct MeaningQuizView: View {
  @Environment(\.
    modelContext
  ) private var modelContext

  @Query private var words: [Word]

  @State private var current: Word?
  @State private var isShowingAnswer = false

  var body: some View {
    VStack(spacing: 16) {
      if let w = current {
        VStack(spacing: 8) {
          Text(w.kanji)
            .font(.system(size: 44, weight: .bold))
          Text(w.hiragana)
            .font(.title3)
            .foregroundStyle(.secondary)
        }

        if isShowingAnswer {
          Text(w.meaningKo)
            .font(.title2)
        } else {
          Text("뜻을 떠올려봐")
            .foregroundStyle(.secondary)
        }

        HStack {
          Button(isShowingAnswer ? "다음" : "정답 보기") {
            if isShowingAnswer {
              nextCard()
            } else {
              isShowingAnswer = true
            }
          }
          .buttonStyle(.borderedProminent)

          if isShowingAnswer {
            Button("맞음") { mark(correct: true) }
              .buttonStyle(.bordered)
            Button("틀림") { mark(correct: false) }
              .buttonStyle(.bordered)
          }
        }
      } else {
        Text("단어가 없어. 먼저 데이터 임포트를 해줘")
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
    .padding()
    .navigationTitle("뜻 퀴즈")
    .onAppear { pickFirst() }
  }

  private func pickFirst() {
    current = words.randomElement()
    isShowingAnswer = false
  }

  private func nextCard() {
    current = words.randomElement()
    isShowingAnswer = false
  }

  private func mark(correct: Bool) {
    guard let w = current else { return }

    modelContext.insert(ReviewLog(wordId: w.id, wasCorrect: correct, mode: "meaning"))
    w.lastReviewedAt = Date()
    w.correctStreak = correct ? (w.correctStreak + 1) : 0

    do { try modelContext.save() } catch { /* ignore */ }
    nextCard()
  }
}
