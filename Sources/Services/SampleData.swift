import Foundation
import SwiftData

enum SampleData {
  static func bootstrapIfNeeded(_ context: ModelContext) async {
    let descriptor = FetchDescriptor<Word>(predicate: nil)
    let existingCount = (try? context.fetchCount(descriptor)) ?? 0
    guard existingCount == 0 else { return }

    // MVP: 샘플 N5 몇 개만
    let words: [Word] = [
      Word(level: "N5", kanji: "学生", hiragana: "がくせい", meaningKo: "학생"),
      Word(level: "N5", kanji: "先生", hiragana: "せんせい", meaningKo: "선생님"),
      Word(level: "N5", kanji: "今日", hiragana: "きょう", meaningKo: "오늘"),
      Word(level: "N5", kanji: "水", hiragana: "みず", meaningKo: "물")
    ]

    words.forEach { context.insert($0) }
    do { try context.save() } catch { /* ignore */ }
  }
}
