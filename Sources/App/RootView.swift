import SwiftUI
import SwiftData

struct RootView: View {
  @Environment(\.
    modelContext
  ) private var modelContext

  var body: some View {
    NavigationStack {
      HomeView()
    }
    .task {
      // 첫 실행시 샘플 데이터 넣기
      await SampleData.bootstrapIfNeeded(modelContext)
      // 알림 권한 요청 + 스케줄
      await NotificationManager.shared.ensurePermissionAndScheduleDaily()
    }
  }
}
