import Foundation
import UserNotifications

final class NotificationManager {
  static let shared = NotificationManager()
  private init() {}

  func ensurePermissionAndScheduleDaily(hour: Int = 9, minute: Int = 0) async {
    let center = UNUserNotificationCenter.current()

    do {
      let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
      guard granted else { return }
      await scheduleDailyWord(hour: hour, minute: minute)
    } catch {
      // 권한 요청 실패는 조용히 무시 (유저가 설정에서 켤 수 있음)
    }
  }

  @MainActor
  func scheduleDailyWord(hour: Int, minute: Int) async {
    let center = UNUserNotificationCenter.current()

    // 중복 방지
    await center.removePendingNotificationRequests(withIdentifiers: ["daily_word"])

    var date = DateComponents()
    date.hour = hour
    date.minute = minute

    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

    let content = UNMutableNotificationContent()
    content.title = "오늘의 단어"
    content.body = "가볍게 1분만! 오늘의 단어 퀴즈 풀어볼까?"
    content.sound = .default

    let request = UNNotificationRequest(identifier: "daily_word", content: content, trigger: trigger)
    do {
      try await center.add(request)
    } catch {
      // 스케줄 실패도 조용히
    }
  }
}
