import Foundation
import SwiftData

@Model
final class Word {
  @Attribute(.unique) var id: UUID

  /// N5~N1
  var level: String

  /// 한자/표기 (예: 日本語)
  var kanji: String

  /// 읽기 (예: にほんご)
  var hiragana: String

  /// 한국어 뜻
  var meaningKo: String

  /// 예문 (MVP에서는 비워두고 나중에 추가)
  var exampleJa: String?
  var exampleKo: String?

  /// 학습 상태
  var createdAt: Date
  var lastReviewedAt: Date?
  var correctStreak: Int

  init(
    level: String,
    kanji: String,
    hiragana: String,
    meaningKo: String,
    exampleJa: String? = nil,
    exampleKo: String? = nil
  ) {
    self.id = UUID()
    self.level = level
    self.kanji = kanji
    self.hiragana = hiragana
    self.meaningKo = meaningKo
    self.exampleJa = exampleJa
    self.exampleKo = exampleKo
    self.createdAt = Date()
    self.lastReviewedAt = nil
    self.correctStreak = 0
  }
}

@Model
final class ReviewLog {
  var id: UUID
  var wordId: UUID
  var createdAt: Date
  var wasCorrect: Bool
  var mode: String // e.g., "meaning"

  init(wordId: UUID, wasCorrect: Bool, mode: String) {
    self.id = UUID()
    self.wordId = wordId
    self.createdAt = Date()
    self.wasCorrect = wasCorrect
    self.mode = mode
  }
}
